class RenameOwnerToOwnerLoginOfProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :owner, :owner_login
  end
end
