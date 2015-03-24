class ChangeOutputInBuildItems < ActiveRecord::Migration
  def up
    change_column :build_items, :output, :text, limit: 4294967295
  end

  def down
    change_column :build_items, :output, :text
  end
end
