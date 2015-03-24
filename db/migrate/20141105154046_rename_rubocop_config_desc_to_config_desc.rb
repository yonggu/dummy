class RenameRubocopConfigDescToConfigDesc < ActiveRecord::Migration
  def change
    rename_table :rubocop_config_descs, :project_config_descs
  end
end
