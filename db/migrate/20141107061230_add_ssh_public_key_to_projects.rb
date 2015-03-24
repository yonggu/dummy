class AddSshPublicKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ssh_public_key, :text
  end
end
