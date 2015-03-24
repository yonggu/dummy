class AddGitUrlAndSshUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :git_url, :string
    add_column :projects, :ssh_url, :string
  end
end
