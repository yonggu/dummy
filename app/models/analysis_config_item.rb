class AnalysisConfigItem < ActiveRecord::Base
  serialize :value
  serialize :options

  belongs_to :analysis_config
  has_many :projects_analysis_config_items, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :analysis_config_id }
end
