class ChangeColumnMessageInOffenses < ActiveRecord::Migration
  def up
    change_column :offenses, :message, :text
  end

  def down
    change_column :offenses, :message, :string
  end
end
