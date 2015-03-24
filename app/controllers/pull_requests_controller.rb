class PullRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_build_item

  def create
    @pull_request = current_user.pull_requests.build pull_request_params.merge(build_item: @build_item)
    if @pull_request.save
      Resque.enqueue PullRequestWorker, @pull_request.id
      render json: true 
    else
      render json: { errors: @pull_request.errors.full_messages }
    end
  end

  private

  def set_build_item
    @build_item = BuildItem.find(params[:build_item_id])
  end

  def pull_request_params
    params.require(:pull_request).permit(:push_directly)
  end
end
