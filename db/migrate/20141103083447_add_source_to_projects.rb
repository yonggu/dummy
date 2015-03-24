class AddSourceToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :source, :integer
  end
end
