class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user
      t.references :project
      t.integer :role

      t.timestamps null: false
    end
  end
end
