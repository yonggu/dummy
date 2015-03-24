module Emails
  module Invitations
    def new_invitation_email(invitation_id)
      @invitation = Invitation.find invitation_id
      @project = @invitation.project
      @sender = @invitation.inviter
      @recipient = User.find_by(email: @invitation.email)

      mail from: 'Awesome Code Invitation <noreply@awesomecode.io>',
           to: @invitation.email,
           subject: "#{@sender.email} invited you to join #{@project.name} on the Awesome Code"
    end
  end
end
