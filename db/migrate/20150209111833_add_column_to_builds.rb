class AddColumnToBuilds < ActiveRecord::Migration
  def up 
    add_column :builds, :success, :boolean

    Build.completed.each do |build|
      build.update_attribute :success, build.build_items.all?(&:passed)
    end
  end

  def down
    remove_column :builds, :success
  end
end
