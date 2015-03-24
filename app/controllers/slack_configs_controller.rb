class SlackConfigsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :find_project, only: [:create, :update]

  def create
    @slack_config = @project.build_slack_config slack_config_params
    if @slack_config.save
      redirect_to project_path(@project), notice: 'Slack config successfully created'
    else
      render 'projects/show'
    end
  end

  def update
    if slack_config_params[:webhook_url].blank?
      @project.slack_config.destroy
    else
      @project.slack_config.update(slack_config_params)
    end
    redirect_to project_path(@project), notice: 'Slack config successfully updated'
  end

  private

  def slack_config_params
    params.require(:slack_config).permit(:webhook_url)
  end

  def find_project
    @project = Project.find params[:project_id]
  end
end
