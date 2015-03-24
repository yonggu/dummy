class CreateIdentitiesAccounts < ActiveRecord::Migration
  def change
    create_table :identities_accounts do |t|
      t.references :identity, index: true
      t.references :account, index: true

      t.timestamps null: false
    end
  end
end
