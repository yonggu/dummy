class AddColumnsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :send_mail, :boolean, default: true
  end
end
