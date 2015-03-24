class AddPassedToBuildItems < ActiveRecord::Migration
  def change
    add_column :build_items, :passed, :boolean
  end
end
