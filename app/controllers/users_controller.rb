class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  load_and_authorize_resource
  skip_authorize_resource only: [:finish_signup]

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      redirect_to root_url, notice: 'Signed in'
    else
      redirect_to root_url, notice: 'Failed to sign in'
    end
  end

  def finish_signup
    @user = User.find(params[:id])
    if @user.update(user_params)
      sign_in @user
      redirect_to root_url, notice: 'Signed in'
    else
      render 'users/add_email'
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, identities_attributes: [:uid, :provider, :access_token])
  end
end
