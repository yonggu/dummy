class ProjectsController < ApplicationController
  before_action :store_location
  before_action :authenticate_user!, except: :status
  load_and_authorize_resource except: :status

  before_action :build_project, only: [:create]

  def new
  end

  def setup_scm
    raise NotImplementedError
  end

  def import
    raise NotImplementedError
  end

  def create
    if @project.save
      redirect_to project_path(@project)
    else
      flash.now[:alert] = @project.errors.values.flatten
      render 'setup_scm'
    end
  end

  def index
    @builds = current_user.builds.includes(:project).order("created_at DESC").page(params[:page])
  end

  def show
    @builds = @project.builds.includes(:project, :build_items).order("created_at DESC").page(params[:page])
  end

  def edit
    @project.build_hipchat_config unless @project.hipchat_config
    @project.build_slack_config unless @project.slack_config
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.json { head :no_content }
        format.html { redirect_to project_path(@project), notice: 'Project was successfully updated.' }
      else
        format.json { render json: { errors: @project.errors }, status: :unprocessable_entity }
        format.html { render 'projects/edit' }
      end
    end
  end

  def status
    @project = Project.find params[:id]
    build = @project.builds.completed.first
    send_file Rails.root.join("public/#{build && build.success? ? 'success' : 'failure'}_badge.png"), type: 'image/png', disposition: 'inline'
  end

  protected

  def build_project
    raise NotImplementedError
  end

  def project_params
    if params[:project]
      params.require(:project).permit(:name, :private, :included_files, :excluded_files, :send_mail,
                                      :slack_config_attributes => [:id, :webhook_url],
                                      :hipchat_config_attributes => [:id, :auth_token, :room]
                                     )
    end
  end
end
