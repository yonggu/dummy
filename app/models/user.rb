class User < ActiveRecord::Base
  ADMIN_EMAILS = %w(flyerhzm@gmail.com zerogy921@gmail.com)
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :identities, dependent: :destroy
  has_many :pull_requests, dependent: :destroy

  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships
  has_many :github_projects, through: :memberships, source: :project, class_name: 'GithubProject'
  has_many :bitbucket_projects, through: :memberships, source: :project, class_name: 'BitbucketProject'

  has_many :builds, through: :projects

  has_many :invitations, foreign_key: :inviter_id, dependent: :destroy

  accepts_nested_attributes_for :identities

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  before_validation :set_password, if: proc { identities.present? && new_record? }

  after_create :create_membership

  scope :admin, -> { where(email: ADMIN_EMAILS) }

  attr_accessor :invitation_token

  def self.find_by_oauth(auth, signed_in_user = nil)
    identity = Identity.find_by_oauth(auth)

    user = signed_in_user || identity.user

    if !user
      email = auth.info.email.presence
      user = User.find_by(email: email) if email
      if !user
        user = User.new(
          name: auth.info.name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20]
        )
        user.save
      end
    end

    if identity.user != user
      identity.user = user
      identity.save
    end

    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  def uid(provider)
    identity(provider).uid
  end

  def access_token(provider)
    identity(provider).access_token
  end

  def access_token_secret(provider)
    identity(provider).access_token_secret
  end

  def identity(provider)
    identities.where(provider: provider).first
  end

  def connected_with?(provider)
    !!identity(provider)
  end

  def github_client
    @github_client ||= Octokit::Client.new(access_token: access_token(:github))
  end

  def bitbucket_client
    @bitbucket_client ||= Bitbucket::Client.new(access_token: access_token(:bitbucket), access_token_secret: access_token_secret(:bitbucket))
  end

  def set_password
    self.password = Devise.friendly_token[0,20]
  end

  def owner_of?(project)
    project.owner == self
  end

  def member_of?(project)
    project.memberships.onwer
  end

  def admin?
    ADMIN_EMAILS.include? self.email
  end

  def avatar_url
    Gravatar.new(self.email).image_url(secure: true)
  end

  private

  def create_membership
    Invitation.pending.where(email: self.email).each do |invitation|
      invitation.project.memberships.create user: self, role: :member
      invitation.update_attributes invitee: self
    end
  end
end
