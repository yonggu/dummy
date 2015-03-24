class RemoveFieldsToBuilds < ActiveRecord::Migration
  def change
    remove_column :builds, :name, :string
    remove_column :builds, :repository_url, :string
  end
end
