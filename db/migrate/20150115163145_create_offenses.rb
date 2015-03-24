class CreateOffenses < ActiveRecord::Migration
  def change
    create_table :offenses do |t|
      t.string :severity
      t.string :message
      t.boolean :corrected
      t.integer :line
      t.integer :column
      t.integer :length
      t.references :build_item, index: true
      t.references :changed_file, index: true

      t.timestamps null: false
    end
  end
end
