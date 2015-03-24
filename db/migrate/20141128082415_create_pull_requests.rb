class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.references :user, index: true
      t.time :sent_at
      t.references :build_item, index: true

      t.timestamps null: false
    end
  end
end
