class CreateUsersAccounts < ActiveRecord::Migration
  def change
    create_table :users_accounts do |t|
      t.references :user, index: true
      t.references :account, index: true

      t.timestamps null: false
    end
  end
end
