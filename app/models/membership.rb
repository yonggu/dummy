class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user, uniqueness: { scope: :project_id }

  enum role: [:owner, :member]
end
