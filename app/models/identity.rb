class Identity < ActiveRecord::Base
  belongs_to :user

  validates :provider, presence: true, uniqueness: { scope: :user_id }
  validates :uid, presence: true

  def self.find_by_oauth(auth)
    identity = find_by(uid: auth.uid, provider: auth.provider)
    if identity
      identity.tap do |identity|
        identity.update_attributes(access_token: auth.credentials.token, access_token_secret: auth.credentials.secret)
      end
    else
      Identity.create(uid: auth.uid, provider: auth.provider,
                      access_token: auth.credentials.token, access_token_secret: auth.credentials.secret)
    end
  end
end
