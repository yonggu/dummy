class AddAcceptedToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :accepted, :boolean, default: false, null: false
  end
end
