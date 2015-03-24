class RemoveAccountsAndUsersAccounts < ActiveRecord::Migration
  def change
    remove_column :projects, :account_id
    drop_table :accounts
    drop_table :users_accounts
  end
end
