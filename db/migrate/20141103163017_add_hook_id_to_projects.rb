class AddHookIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :hook_id, :integer
  end
end
