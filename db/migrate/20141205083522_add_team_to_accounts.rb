class AddTeamToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :team, :boolean
  end
end
