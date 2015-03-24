class AddTypeToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :type, :string

    Project.find_each do |project|
      project.update_attributes type: "#{project.source}_project".camelize
    end

    remove_column :projects, :source
  end

  def down
    remove_column :projects, :type
    add_column :projects, :source, :integer
  end
end
