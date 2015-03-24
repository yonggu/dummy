class RemoveConfigKeyFromBuildItems < ActiveRecord::Migration
  def change
    remove_column :build_items, :config_key
  end
end
