class AddInviterIdAndInviteeIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :inviter_id, :integer, index: true
    add_column :invitations, :invitee_id, :integer, index: true
  end
end
