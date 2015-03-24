class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.references :project, index: true
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
