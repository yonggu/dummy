class OmniauthCallbacksController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  def create
    @user = User.find_by_oauth(request.env['omniauth.auth'], current_user)
    if @user.email_verified?
      sign_in @user
      flash[:notice] = "#{ request.env['omniauth.auth'].provider.capitalize } Connected successfully."
      redirect_to_stored_location_or_root_path
    else
      @user.email = ''
      render 'users/add_email'
    end
  end

  def destroy
    reset_session
    redirect_to unauthenticated_root_path, notice: 'Signed out successfully.'
  end

  def failure
    redirect_to unauthenticated_root_path, alert: 'Failed to authenticate. Please try it again.'
  end
end
