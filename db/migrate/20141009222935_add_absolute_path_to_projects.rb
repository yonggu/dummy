class AddAbsolutePathToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :absolute_path, :string
  end
end
