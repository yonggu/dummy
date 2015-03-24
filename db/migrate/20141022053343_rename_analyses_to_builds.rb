class RenameAnalysesToBuilds < ActiveRecord::Migration
  def change
    rename_table :analyses, :builds
  end
end
