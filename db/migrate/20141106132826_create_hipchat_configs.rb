class CreateHipchatConfigs < ActiveRecord::Migration
  def change
    create_table :hipchat_configs do |t|
      t.string :auth_token
      t.string :room
      t.references :project, index: true

      t.timestamps null: false
    end
  end
end
