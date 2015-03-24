class AddInvitationIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :invitation, index: true
    add_foreign_key :users, :invitations
  end
end
