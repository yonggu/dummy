class AddProjectsAnalysisConfigIdToBuildItems < ActiveRecord::Migration
  def change
    add_reference :build_items, :projects_analysis_config, index: true
  end
end
