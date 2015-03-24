class DropTableProjectsAccounts < ActiveRecord::Migration
  def change
    drop_table :projects_accounts
  end
end
