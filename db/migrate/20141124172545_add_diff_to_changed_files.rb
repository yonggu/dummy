class AddDiffToChangedFiles < ActiveRecord::Migration
  def change
    add_column :changed_files, :diff, :text
  end
end
