class CreateProjectsAnalysisConfigs < ActiveRecord::Migration
  def change
    create_table :projects_analysis_configs do |t|
      t.references :project, index: true
      t.references :analysis_config, index: true
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
