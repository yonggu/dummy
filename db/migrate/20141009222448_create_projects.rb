class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.text :origin_report_content, limit: 4294967295

      t.timestamps
    end
  end
end
