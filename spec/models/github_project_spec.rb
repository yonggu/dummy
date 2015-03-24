require 'rails_helper'

describe GithubProject do
  let(:user) { create :user, email: 'test@test.com' }
  let!(:identity) { create :identity, provider: :github, user: user, access_token: '12345678' }
  let(:project) { create :github_project, name: "Owner/Test GithubProject" }
  let!(:membership) { create :membership, user: user, project: project, role: :owner }

  describe "#activate" do
    context "when the user has admin privilege" do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:repository) { { permissions: { admin: true } } }
        allow_any_instance_of(Octokit::Client).to receive(:hooks) { [] }
        allow_any_instance_of(Octokit::Client).to receive(:create_hook) { { id: 20 } }
        allow_any_instance_of(Octokit::Client).to receive(:add_deploy_key) { { id: 20 } }
      end

      it { expect(project.activate).to be_truthy }

      it "saves hook_id" do
        project.activate
        project.reload
        expect(project.hook_id).to eq(20)
      end
    end

    context "when the user does not have admin privilege" do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:repository).with(project.name) { { permissions: { admin: false } } }
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
      project.hook_id = 20
      project.save
    end

    context "when the user has admin privilege" do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:repository) { { permissions: { admin: true } } }
        allow_any_instance_of(Octokit::Client).to receive(:remove_hook)
      end

      it { expect(project.remove_scm).to be_truthy }

      it "sets hook_id to nil" do
        project.remove_scm
        project.reload
        expect(project.hook_id).to be_nil
      end
    end

    context "when the user does not have admin privilege" do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:repository).with(project.name) { { permissions: { admin: false } } }
      end

      it { expect(project.remove_scm).to be_falsy }
    end
  end

  describe ".import" do
    before do
      allow_any_instance_of(Octokit::Client).to receive(:repositories) { [] }
      allow_any_instance_of(Octokit::Client).to receive(:organizations) { [{:login=>"xinminlabs",
                                                                            :id=>3224103,
                                                                            :url=>"https://api.github.com/orgs/xinminlabs",
                                                                            :repos_url=>"https://api.github.com/orgs/xinminlabs/repos",
                                                                            :events_url=>"https://api.github.com/orgs/xinminlabs/events",
                                                                            :members_url=>"https://api.github.com/orgs/xinminlabs/members{/member}",
                                                                            :public_members_url=>
                                                                                "https://api.github.com/orgs/xinminlabs/public_members{/member}",
                                                                            :avatar_url=>"https://avatars.githubusercontent.com/u/3224103?v=3"}
      ] }
      allow_any_instance_of(Octokit::Client).to receive(:org_repos) { [{name: 'test123', ssh_url: 'http://fake123.com', owner: {login: 'dummy'}}] }
      allow_any_instance_of(Octokit::Client).to receive(:user) { {:login=>"yaonie084",
                                                                  :id=>335502,
                                                                  :avatar_url=>"https://avatars.githubusercontent.com/u/335502?v=3"} }
    end

    it "returns an array of GithubProject" do
      expect(GithubProject.import(user).map{|project| { name: project.name }}).to eq [name: 'dummy/test123']
    end
  end

  describe "#commit_url" do
    it { expect(project.commit_url('123456')).to eq('https://github.com/Owner/Test GithubProject/commit/123456') }
  end

  describe '#clone_url' do
    it { expect(project.clone_url).to eq('https://12345678:x-oauth-basic@github.com/Owner/Test GithubProject.git') }
  end

  describe '#pushable_for?' do
    context 'when the user is connected with github' do
      it { expect(project.pushable_for?(user)).to be_truthy }
    end

    context 'when the user is not connected with github' do
      before do
        user.identities.delete_all
      end

      it { expect(project.pushable_for?(user)).to be_falsey }
      
      it 'returns error on base' do
        project.pushable_for?(user)
        expect(project.errors[:base]).to eq ['You have not connected your Github account yet.']
      end
    end
  end
end
