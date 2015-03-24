class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_job

  respond_to :json

  def show
    render json: { status: @job.status, errors: @job['errors'] }
  end

  private

  def find_job
    @job = Resque::Plugins::Status::Hash.get(params[:id])
  end
end
