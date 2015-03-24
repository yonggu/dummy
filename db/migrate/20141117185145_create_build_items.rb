class CreateBuildItems < ActiveRecord::Migration
  def change
    create_table :build_items do |t|
      t.references :build, index: true
      t.string :config_key
      t.text :output
      t.timestamps null: false
    end
  end
end
