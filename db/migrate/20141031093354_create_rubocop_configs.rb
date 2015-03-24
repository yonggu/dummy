class CreateRubocopConfigs < ActiveRecord::Migration
  def change
    create_table :rubocop_configs do |t|
      t.text :content
      t.references :project, index: true

      t.timestamps null: false
    end
  end
end
