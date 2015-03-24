class NewInvitationEmailWorker
  @queue = :email

  def self.perform(invitation_id)
    Notifier.new_invitation_email invitation_id
  end
end
