class AddAccountIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :account_id, :integer, index: true
  end
end
