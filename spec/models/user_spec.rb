require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:github_projects) { create_list :github_project, 2 }
  let(:bitbucket_projects) { create_list :bitbucket_project, 2 }

  describe ".find_by_oauth" do
    let(:auth) { OmniAuth.config.mock_auth[:bitbucket] }

    context "with oauth email" do
      before do
        valid_bitbucket_login_setup info: { email: 'test@xinminlabs.com' }
      end

      context "when user and identity exist" do
        let!(:user) { create :user, email: 'test@xinminlabs.com' }
        let!(:identity) { create(:identity, uid: auth['uid'], provider: auth['provider'], user: user) }

        it "returns the existing user" do
          expect {
            expect(User.find_by_oauth(auth)).to eq user
          }.to change { User.count }.by(0)
        end

        it "doesn't create identity" do
          expect { User.find_by_oauth(auth) }.not_to change { Identity.count }
        end
      end

      context "when user exists but identity doesn't" do
        let!(:user) { create :user, email: 'test@xinminlabs.com' }

        it "returns the existing user" do
          expect {
            expect(User.find_by_oauth(auth)).to eq user
          }.to change { User.count }.by(0)
        end

        it "creates an identity" do
          expect { User.find_by_oauth(auth) }.to change { Identity.count }.by(1)
        end
      end

      context "when user and identity don't exist" do
        it "adds a new user" do
          expect(User.find_by_oauth(auth)).to be_persisted
        end
      end

      context "with signed_in_user" do
        let!(:user) { create :user }

        it "binds user with identity" do
          expect {
            User.find_by_oauth(auth, user)
          }.to change { Identity.count }.by(1)
          identity = Identity.last
          expect(identity.user).to eq user
        end
      end
    end

    context "without oauth email" do
      before do
        valid_bitbucket_login_setup
      end

      it "creates a fake user" do
        user = User.find_by_oauth(auth)
        expect(user).not_to be_email_verified
      end
    end
  end

  describe "#identity" do
    let!(:user) { create :user }
    let!(:identity_github) { create :identity, provider: 'github', user: user }
    let!(:identity_bitbucket) { create :identity, provider: 'bitbucket', user: user }

    it "should return identity_github" do
      expect(user.identity('github')).to eq identity_github
    end

    it "should return identity_bitbucket" do
      expect(user.identity('bitbucket')).to eq identity_bitbucket
    end
  end

  describe "#uid" do
    let!(:user) { create :user }
    let!(:github_identity) { create :identity, user: user, uid: '123', provider: 'github' }
    let!(:bitbucket_identity) { create :identity, user: user, uid: '456', provider: 'bitbucket' }

    it "should return 123" do
      expect(user.uid('github')).to eq '123'
    end

    it "should return 456" do
      expect(user.uid('bitbucket')).to eq '456'
    end
  end

  describe '#create_membership' do
    let(:user) { create :user }
    let(:project) { create :project, owner: user }

    context 'when the email exists in the invitation' do
      before do
        @invitation = Invitation.create project: project, inviter: user, email: 'recipient@xinminlabs.com'
      end

      it {
        expect {
          create :user, email: 'recipient@xinminlabs.com'
        }.to change{ project.memberships.count }.by(1)
      }

      it {
        create :user, email: 'recipient@xinminlabs.com'
        expect(@invitation.reload.invitee).not_to be_nil
      }
    end

    context 'when the email does not exist in the invitation' do
      it {
        expect {
          create :user, email: 'recipient@xinminlabs.com'
        }.to change{ project.memberships.count }.by(0)
      }
    end
  end
end
