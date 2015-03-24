class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project
  before_action :find_membership, only: [:destroy]

  def destroy
    if @membership.owner?
      flash[:alert] = 'You can not remove the owner.'
    else
      @membership.destroy
      flash[:notice] = "You have removed #{@membership.user.name} from this project."
    end
    redirect_to edit_project_path(@project, anchor: 'memberships')
  end

  private

  def find_project
    @project = Project.find params[:project_id]
  end

  def find_membership
    @membership = @project.memberships.find params[:id]
  end
end
