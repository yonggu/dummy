class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :project, index: true
      t.string :email, index: true
      t.references :user, index: true
      t.string :aasm_state

      t.timestamps null: false
    end
    add_foreign_key :invitations, :projects
    add_foreign_key :invitations, :users
  end
end
