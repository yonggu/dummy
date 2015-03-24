class RemoveInvitationIdFromUsers < ActiveRecord::Migration
  def change
    remove_foreign_key :users, :invitations
    remove_column :users, :invitation_id
  end
end
