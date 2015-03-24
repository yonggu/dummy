require 'rails_helper'

RSpec.describe Identity, :type => :model do
  let(:user) { create :user, name: nil }
  let(:identity) { create :identity, user: user, provider: :github }

  describe "validations" do
    it { is_expected.to validate_presence_of :provider }
    it { is_expected.to validate_presence_of :uid }

    it 'validates uniquess of provider scoped to user_id' do
      identity.touch
      expect {
        create(:identity, user: user, provider: :github).errors
      }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Provider has already been taken')
    end
  end

  describe ".find_by_oauth" do
    let(:auth) { OmniAuth.config.mock_auth[:bitbucket] }

    context "when identity doesn't exist" do
      it "creates an identity" do
        valid_bitbucket_login_setup uid: '123456', provider: 'bitbucket'
        expect {
          Identity.find_by_oauth(auth)
          identity = Identity.last
          expect(identity.uid).to eq '123456'
          expect(identity.provider).to eq 'bitbucket'
        }.to change { Identity.count }.by(1)
      end
    end

    context "when identity exists" do
      it "updates an identity" do
        identity = create :identity, uid: '123456', provider: 'bitbucket'
        valid_bitbucket_login_setup uid: '123456', credentials: { token: 'bitbucket-token', secret: 'bitbucket-secret' }
        expect {
          Identity.find_by_oauth(auth)
          identity.reload
          expect(identity.access_token).to eq 'bitbucket-token'
          expect(identity.access_token_secret).to eq 'bitbucket-secret'
        }.to change { Identity.count }.by(0)
      end
    end
  end
end
