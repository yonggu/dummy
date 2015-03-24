class AddRunRailsCopIntoProjects < ActiveRecord::Migration
  def change
    add_column :projects, :run_rails_cops, :boolean, default: false
  end
end
