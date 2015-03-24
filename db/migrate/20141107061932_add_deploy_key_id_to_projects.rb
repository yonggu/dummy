class AddDeployKeyIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :deploy_key_id, :integer
  end
end
