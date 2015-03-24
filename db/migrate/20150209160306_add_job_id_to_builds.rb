class AddJobIdToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :job_id, :string
  end
end
