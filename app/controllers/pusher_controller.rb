class PusherController < ApplicationController
  protect_from_forgery :except => :auth

  def auth
    if current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])

      project_id = params[:channel_name].split('-').last.to_i
      if (project = Project.find_by(id: project_id)) && can?(:read, project)
        render json: response
      else
        render text: 'Forbidden', status: '403'
      end
    else
      render text: 'Forbidden', status: '403'
    end
  end
end
