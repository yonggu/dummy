class RenameSyncTimeToLastSyncedAtInAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :sync_time, :last_synced_at
  end
end
