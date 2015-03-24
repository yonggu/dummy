class HipchatConfigsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :find_project, only: [:create, :update]

  def create
    @hipchat_config = @project.build_hipchat_config hipchat_config_params
    if @hipchat_config.save
      redirect_to project_path(@project), notice: 'Hipchat config successfully created'
    else
      render 'projects/show'
    end
  end

  def update
    if hipchat_config_params[:auth_token].blank? || hipchat_config_params[:room].blank?
      @project.hipchat_config.destroy
    else
      @project.hipchat_config.update(hipchat_config_params)
    end
    redirect_to project_path(@project), notice: 'Hipchat config successfully updated'
  end

  private

  def hipchat_config_params
    params.require(:hipchat_config).permit(:auth_token, :room)
  end

  def find_project
    @project = Project.find params[:project_id]
  end
end
