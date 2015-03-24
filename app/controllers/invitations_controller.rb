class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project

  def create
    @invitation = @project.invitations.build invitation_params.merge(inviter: current_user)

    if @invitation.save
      flash[:notice] = "You invited #{@invitation.email} to #{@project.name}."
    else
      flash[:alert] = @invitation.errors.full_messages
    end

    redirect_to edit_project_path(@project, anchor: 'memberships')
  end

  private

  def find_project
    @project = Project.find params[:project_id]
  end

  def invitation_params
    params.require(:invitation).permit(:email)
  end
end
