require 'rails_helper'

RSpec.describe Invitation, :type => :model do
  let(:user) { create :user }
  let(:project) { create :project, owner: user }
  let(:recipient) { create :user, email: 'recipient@xinminlabs.com' }

  describe "#create_membership" do
    context "when user with the email exists" do
      it 'creates membership' do
        expect { Invitation.create project: project, inviter: user, email: recipient.email }.to change{ project.memberships.count }.by(1)
      end
    end

    context "when user with the email does not exist" do
      it 'does not create membership' do
        expect { Invitation.create project: project, inviter: user, email: 'test@xinminlabs.com' }.to change{ project.memberships.count }.by(0)
      end
    end
  end

  describe "#set_token" do
    let(:invitation) { create :invitation }
    it { expect(invitation.token).to be_present }
  end
end
