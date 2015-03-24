class AddIncludedFilesAndExcludedFilesIntoProjects < ActiveRecord::Migration
  def change
    add_column :projects, :included_files, :text
    add_column :projects, :excluded_files, :text
  end
end
