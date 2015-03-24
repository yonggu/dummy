class CreateAnalysisConfigs < ActiveRecord::Migration
  def change
    create_table :analysis_configs do |t|
      t.string :name
      t.text :description
      t.string :guide
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
