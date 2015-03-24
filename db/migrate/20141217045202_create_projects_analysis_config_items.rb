class CreateProjectsAnalysisConfigItems < ActiveRecord::Migration
  def change
    create_table :projects_analysis_config_items do |t|
      t.references :projects_analysis_config
      t.references :analysis_config_item
      t.string :value

      t.timestamps null: false
    end

    add_index :projects_analysis_config_items, :projects_analysis_config_id, name: 'by_projects_analysis_config'
    add_index :projects_analysis_config_items, :analysis_config_item_id, name: 'by_analysis_config_item'
  end
end
