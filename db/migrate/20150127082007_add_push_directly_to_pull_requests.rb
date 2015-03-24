class AddPushDirectlyToPullRequests < ActiveRecord::Migration
  def change
    add_column :pull_requests, :push_directly, :boolean
  end
end
