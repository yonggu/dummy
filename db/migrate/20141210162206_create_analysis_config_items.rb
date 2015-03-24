class CreateAnalysisConfigItems < ActiveRecord::Migration
  def change
    create_table :analysis_config_items do |t|
      t.references :analysis_config, index: true
      t.string :name
      t.string :value
      t.string :options

      t.timestamps null: false
    end
  end
end
