class BuildsController < ApplicationController
  before_action :store_location
  before_action :authenticate_user!, except: [:create]
  load_and_authorize_resource except: [:create]

  before_action :set_project, only: [:create, :show]

  skip_before_filter :verify_authenticity_token

  def create
    if params[:payload]
      @build = @project.builds.build_from_bitbucket(JSON[params[:payload]])
    else
      @build = @project.builds.build_from_github(params)
    end

    if @build.save
      @build.start!
    end

    render nothing: true
  end

  def show
  end

  def rebuild
    @build.rebuild!

    render :json => true
  end

  def stop
    @build.stop!

    render :json => true
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
