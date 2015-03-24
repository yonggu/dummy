class CreateProjectsAccounts < ActiveRecord::Migration
  def change
    create_table :projects_accounts do |t|
      t.references :project, index: true
      t.references :account, index: true
      t.integer :role

      t.timestamps null: false
    end
  end
end
