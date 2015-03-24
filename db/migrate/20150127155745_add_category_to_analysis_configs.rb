class AddCategoryToAnalysisConfigs < ActiveRecord::Migration
  def up
    add_column :analysis_configs, :category, :string

    AnalysisConfig.find_each do |analysis_config|
      analysis_config.update_attributes category: analysis_config.name.split("/").first
    end
  end

  def down
    remove_column :analysis_configs, :category
  end
end
