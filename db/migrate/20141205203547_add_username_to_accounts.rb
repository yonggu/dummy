class AddUsernameToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :username, :string
  end
end
