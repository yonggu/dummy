class AddForkAndPrivateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :private, :boolean
    add_column :projects, :fork, :boolean
  end
end
