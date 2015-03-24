class CreateRubocopConfigDescs < ActiveRecord::Migration
  def change
    create_table :rubocop_config_descs do |t|
      t.string :title, index: true
      t.text :desc

      t.timestamps null: false
    end
  end
end
