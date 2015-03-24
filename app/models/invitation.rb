class Invitation < ActiveRecord::Base
  belongs_to :project

  belongs_to :inviter, class_name: 'User'
  belongs_to :invitee, class_name: 'User'

  validates :inviter, presence: true
  validates :email, presence: true, uniqueness: { scope: :project_id, message: 'has been invited.' }

  scope :pending, -> { where(invitee_id: nil) }
  scope :accepted, -> { where.not(invitee_id: nil) }

  after_create :create_membership
  after_commit :send_new_invitation_email, on: :create
  before_create :set_token

  private

  def create_membership
    recipient = User.find_by(email: self.email)

    if recipient
      project.memberships.create user: recipient, role: :member
    end
  end

  def send_new_invitation_email
    Resque.enqueue NewInvitationEmailWorker, self.id
  end

  def set_token
    self.token = Devise.friendly_token[0, 20]
  end
end
