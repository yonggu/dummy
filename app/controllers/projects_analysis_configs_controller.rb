class ProjectsAnalysisConfigsController < ApplicationController
  before_action :authenticate_user!, only: [:toggle, :update]
  before_action :set_projects_analysis_config, only: [:toggle, :update]

  def toggle
    if @projects_analysis_config.toggle! :enabled
      head :no_content
    else
      render json: { errors: @projects_analysis_config.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @projects_analysis_config.update_attributes projects_analysis_config_params
      head :no_content
    else
      render json: { errors: @projects_analysis_config.errors }, status: :unprocessable_entity
    end
  end

  private

    def set_projects_analysis_config
      @projects_analysis_config = ProjectsAnalysisConfig.find params[:id]
    end

    def projects_analysis_config_params
      params.require(:projects_analysis_config).permit(:projects_analysis_config_items_attributes => [:id, :value])
    end
end
