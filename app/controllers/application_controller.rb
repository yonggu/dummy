class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  before_action :store_invitation_token

  protected

  def redirect_to_stored_location_or_root_path
    redirect_to stored_location_for(:user) || root_path
  end

  private

  def store_invitation_token
    session[:invitation_token] = params[:invitation_token] if params[:invitation_token].present?
  end

  def store_location
    if request.get?
      store_location_for :user, request.path
    end
  end
end
