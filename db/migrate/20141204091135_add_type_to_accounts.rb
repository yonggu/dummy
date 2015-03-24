class AddTypeToAccounts < ActiveRecord::Migration
  def up
    add_column :accounts, :type, :string
    remove_column :accounts, :source
  end

  def down
    remove_column :accounts, :type
    add_column :accounts, :source, :integer
  end
end
