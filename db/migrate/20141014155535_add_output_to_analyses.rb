class AddOutputToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :output, :text
  end
end
