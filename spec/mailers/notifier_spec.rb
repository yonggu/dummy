require "rails_helper"

RSpec.describe Notifier, :type => :mailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user) { create :user, email: 'sender@xinminlabs.com' }
  let(:project) { create :project, name: 'xinminlabs/coding_style_guide' }

  describe '#new_invitation_email' do
    let(:invitation) { create :invitation, project: project, inviter: user, email: 'recipient@xinminlabs.com' }

    subject { Notifier.new_invitation_email(invitation.id) }

    it 'is sent from Awesome Code' do
      sender = subject.header[:from].addrs[0]
      expect(sender.display_name).to eq('Awesome Code Invitation')
      expect(sender.address).to eq('noreply@awesomecode.io')
    end

    it { expect(subject).to deliver_to 'recipient@xinminlabs.com' }
    it { expect(subject).to have_subject 'sender@xinminlabs.com invited you to join xinminlabs/coding_style_guide on the Awesome Code' }
    context 'when the user with email exists' do
      it { expect(subject).to have_body_text(project_url(project)) }
    end

    context 'when the user with email does not exist' do
      it { expect(subject).to have_body_text(project_url(project, invitation_token: invitation.token)) }
    end
  end

  describe '#build_finished_email' do
    let(:users) { create_list :user, 2 }
    let!(:project) { create :bitbucket_project, name: 'Owner/Project', git_url: 'https://bitbucket.org/yaonie084/experiments.git' }
    let!(:build) do
      create :build,
             started_at: Time.now,
             finished_at: Time.now,
             aasm_state: :running,
             branch: 'test_branch',
             author: 'test_user',
             author_email: '123@xinminlabs.com',
             last_commit_id: '8c5ef22eacd687c12b8827d97406388f37ca246f',
             last_commit_message: 'aa',
             project: project
    end

    before do
      allow(Gravatar).to receive(:new) { double(image_url: '123') }
      project.users = users
    end

    context "when sends mail for failed build" do
      before do
        build.update_attributes success: false
      end

      subject { Notifier.build_finished_email(build.id) }

      it 'is sent from Awesome Code' do
        sender = subject.header[:from].addrs[0]
        expect(sender.display_name).to eq('Awesome Code Build')
        expect(sender.address).to eq('notification@awesomecode.io')
      end

      it { expect(subject).to have_subject 'Build notification' }
      it { expect(subject).to deliver_to users.map(&:email) }
      it { expect(subject).to have_body_text(build.project.commit_url(build.last_commit_id)) }
      it { expect(subject).to have_body_text(build.absolute_url) }
      it { expect(subject).to have_body_text(project.absolute_url) }
      it { expect(subject).to have_body_text(build.author) }
      it { expect(subject).to have_body_text(build.author_avatar_url) }
      it { expect(subject).to have_body_text(build.branch) }
      it { expect(subject).to have_body_text('failed') }
    end

    context "when sends mail for recovered build" do
      let!(:last_build) do
        create :build,
               started_at: Time.now,
               finished_at: Time.now,
               aasm_state: :completed,
               branch: 'test_branch',
               author: 'test_user',
               author_email: '456@xinminlabs.com',
               last_commit_id: '456456788687c12b8827d97406388f37ca246f',
               last_commit_message: 'adfdcd',
               project: project,
               success: true
      end

      subject { Notifier.build_finished_email(last_build.id) }

      it 'is sent from Awesome Code' do
        sender = subject.header[:from].addrs[0]
        expect(sender.display_name).to eq('Awesome Code Build')
        expect(sender.address).to eq('notification@awesomecode.io')
      end

      it { expect(subject).to have_subject 'Build notification' }
      it { expect(subject).to deliver_to users.map(&:email) }
      it { expect(subject).to have_body_text(last_build.project.commit_url(build.last_commit_id)) }
      it { expect(subject).to have_body_text(last_build.absolute_url) }
      it { expect(subject).to have_body_text(project.absolute_url) }
      it { expect(subject).to have_body_text(last_build.author) }
      it { expect(subject).to have_body_text(last_build.author_avatar_url) }
      it { expect(subject).to have_body_text(last_build.branch) }
      it { expect(subject).to have_body_text('recovered') }
      it { expect(subject).to have_body_text(build.last_commit_id) }
    end
  end
end
