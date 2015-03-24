class AddOwnerUidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :owner_uid, :string
  end
end
