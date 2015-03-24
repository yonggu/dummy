require 'rails_helper'

describe BitbucketProject do
  let(:user) { create :user, email: "test@test.com" }
  let!(:identity) { create :identity, provider: :bitbucket, user: user }
  let(:project) { create :bitbucket_project, name: "Owner/Test BitbucketProject" }
  let!(:membership) { create :membership, user: user, project: project, role: :owner }
  let(:ssh_public_key) { "This is a public key" }

  describe "#activate" do
    context "when the user has admin privilege" do
      before do
        allow_any_instance_of(Bitbucket::Client).to receive(:privileges) { [] }
        allow_any_instance_of(Bitbucket::Client).to receive(:services).with('Owner/Test BitbucketProject') { [] }
        allow_any_instance_of(Bitbucket::Client).to receive(:create_service).with('Owner/Test BitbucketProject', project.send(:hook_url)) { { "id" => 5 } }
        allow(project).to receive(:generate_ssh_public_key) { ssh_public_key }
        allow_any_instance_of(Bitbucket::Client).to receive(:deploy_keys).with('Owner/Test BitbucketProject') { [] }
        allow_any_instance_of(Bitbucket::Client).to receive(:create_deploy_key).with('Owner/Test BitbucketProject', ssh_public_key, 'Awesome Code') { { "pk" => 20 } }
      end

      it { expect(project.activate).to be_truthy }

      it "saves hook_id" do
        project.activate
        project.reload
        expect(project.hook_id).to eq(5)
      end

      it "saves deploy_key_id" do
        project.activate
        project.reload
        expect(project.deploy_key_id).to eq(20)
      end
    end

    context "when the user does not have admin privilege" do
      before do
        allow_any_instance_of(Bitbucket::Client).to receive(:privileges) { 'None' }
      end

      it { expect{ project.activate }.to raise_error(ActiveRecord::RecordInvalid) }

      it "adds error to base" do
        project.activate rescue nil
        expect(project.errors[:base]).to eq(["You cannot configure this repository. Please contact the administrator to set up the project for you!"])
      end
    end
  end

  describe "#remove_scm" do
    before do
      project.hook_id = 5
      project.deploy_key_id = 20
      project.save
    end

    context "when the user has admin privilege" do
      before do
        allow_any_instance_of(Bitbucket::Client).to receive(:privileges) { [] }
        allow_any_instance_of(Bitbucket::Client).to receive(:delete_service).with('Owner/Test BitbucketProject', 5)
        allow_any_instance_of(Bitbucket::Client).to receive(:delete_deploy_key).with('Owner/Test BitbucketProject', 20)
      end

      it { expect(project.remove_scm).to be_truthy }

      it "saves hook_id" do
        project.remove_scm
        project.reload
        expect(project.hook_id).to be_nil
      end

      it "saves deploy_key_id" do
        project.remove_scm
        project.reload
        expect(project.deploy_key_id).to be_nil
      end
    end

    context "when the user does not have admin privilege" do
      before do
        allow_any_instance_of(Bitbucket::Client).to receive(:privileges) { 'None' }
      end

      it { expect(project.remove_scm).to be_falsy }

      it "adds error to base" do
        project.remove_scm
        expect(project.errors[:base]).to eq(["You cannot configure this repository. Please contact the administrator to set up the project for you!"])
      end
    end
  end

  describe ".import" do
    let(:user_repositories_response) { load_bitbucket_user_repositories }
    let(:user_response) { load_bitbucket_user }

    before do
      allow_any_instance_of(Bitbucket::Client).to receive(:repositories) { user_repositories_response }
      user_repositories_response.each do |repo|
        allow_any_instance_of(Bitbucket::Client).to receive(:user).with(repo['owner']) { user_response }
      end
    end

    it "returns an array of BitbucketProject" do
      expect(BitbucketProject.import(user).map{|project| { name: project.name }}).to eq [name: '1team/justdirectteam']
    end
  end

  describe '#commit_url' do
    it { expect(project.commit_url('123456')).to eq('https://bitbucket.org/Owner/Test BitbucketProject/commits/123456') }
  end

  describe '#clone_url' do
    it { expect(project.clone_url).to eq('git@bitbucket.org:Owner/Test BitbucketProject.git') }
  end

  describe '#pushable_for?' do
    context 'when the user is connected with bitbucket' do
      it { expect(project.pushable_for?(user)).to be_truthy }
    end

    context 'when the user is not connected with bitbucket' do
      before do
        user.identities.delete_all
      end

      it { expect(project.pushable_for?(user)).to be_falsey }
      
      it 'returns error on base' do
        project.pushable_for?(user)
        expect(project.errors[:base]).to eq ['You have not connected your Bitbucket account yet.']
      end
    end
  end
end
