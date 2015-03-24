class Offense < ActiveRecord::Base
  belongs_to :build_item
  belongs_to :changed_file
end
