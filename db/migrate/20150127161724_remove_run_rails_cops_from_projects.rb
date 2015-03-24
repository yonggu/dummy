class RemoveRunRailsCopsFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :run_rails_cops
  end
end
