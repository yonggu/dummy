class RemoveKindFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :kind
  end
end
