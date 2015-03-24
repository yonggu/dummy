class CreateChangedFiles < ActiveRecord::Migration
  def change
    create_table :changed_files do |t|
      t.string :path
      t.references :build_item, index: true
      t.text :original_content
      t.text :corrected_content

      t.timestamps null: false
    end
  end
end
