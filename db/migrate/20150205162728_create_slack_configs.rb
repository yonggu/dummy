class CreateSlackConfigs < ActiveRecord::Migration
  def change
    create_table :slack_configs do |t|
      t.string :webhook_url
      t.references :project, index: true
    end
    add_foreign_key :slack_configs, :projects
  end
end
