class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :uid
      t.string :avatar_url
      t.integer :kind
      t.datetime :sync_time
      t.timestamps null: false
    end
  end
end
