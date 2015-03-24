class AddColumnsToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :name, :string
    add_column :analyses, :repository_url, :string
    add_column :analyses, :branch, :string
    add_column :analyses, :last_commit_id, :string
    add_column :analyses, :author, :string
    add_column :analyses, :last_commit_message, :text
  end
end
