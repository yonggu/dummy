class RenameRubocopConfigToConfig < ActiveRecord::Migration
  def change
    rename_table :rubocop_configs, :project_configs
  end
end
