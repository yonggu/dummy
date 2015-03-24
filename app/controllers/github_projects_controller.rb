class GithubProjectsController < ProjectsController
  before_action :redirect_unless_github_is_connected, only: [:setup_scm, :import]

  def setup_scm
  end

  def import
    projects = GithubProject.import(current_user)
    render partial: 'projects/project_list', locals: { projects: projects }
  end

  protected

  def build_project
    @project = current_user.github_projects.build project_params.merge(owner: current_user)
  end

  def redirect_unless_github_is_connected
    redirect_to '/auth/github' unless current_user.connected_with?(:github)
  end
end
