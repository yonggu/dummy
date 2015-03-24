class BitbucketProjectsController < ProjectsController
  before_action :redirect_unless_bitbucket_is_connected, only: [:setup_scm, :import]

  def setup_scm
  end

  def import
    projects = BitbucketProject.import(current_user)
    render partial: 'projects/project_list', locals: { projects: projects }
  end

  protected

  def build_project
    @project = current_user.bitbucket_projects.build project_params.merge(owner: current_user)
  end

  def redirect_unless_bitbucket_is_connected
    redirect_to '/auth/bitbucket' unless current_user.connected_with?(:bitbucket)
  end
end
