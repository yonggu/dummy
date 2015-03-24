class AddAuthorEmailToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :author_email, :string, default: ''
  end
end
