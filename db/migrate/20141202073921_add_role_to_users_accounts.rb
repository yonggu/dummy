class AddRoleToUsersAccounts < ActiveRecord::Migration
  def change
    add_column :users_accounts, :role, :integer
  end
end
