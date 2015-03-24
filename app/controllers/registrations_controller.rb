class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def create
    super

    if session[:invitation_token].present?
      invitation = Invitation.find_by token: session[:invitation_token]
      invitation.update_attribute :accepted, true
      session[:invitation_token] = nil
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
