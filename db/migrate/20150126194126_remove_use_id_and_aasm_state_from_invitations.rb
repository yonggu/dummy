class RemoveUseIdAndAasmStateFromInvitations < ActiveRecord::Migration
  def change
    remove_foreign_key :invitations, :users
    remove_column :invitations, :user_id
    remove_column :invitations, :aasm_state
  end
end
