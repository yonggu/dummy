class DropTableIdentitiesAccounts < ActiveRecord::Migration
  def change
    drop_table :identities_accounts
  end
end
