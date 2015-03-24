class ChangeColumnOutputInAnalyses < ActiveRecord::Migration
  def self.up
    change_column :analyses, :output, :text, limit: 4294967295
  end

  def self.down
    change_column :analyses, :output, :text
  end
end
