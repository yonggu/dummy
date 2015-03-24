class Notifier < ActionMailer::Base
  layout 'notifier'

  include Emails::Invitations
  include Emails::Builds
end
