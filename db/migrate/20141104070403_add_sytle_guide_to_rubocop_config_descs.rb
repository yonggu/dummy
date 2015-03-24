class AddSytleGuideToRubocopConfigDescs < ActiveRecord::Migration
  def change
    add_column :rubocop_config_descs, :style_guide, :string
  end
end
