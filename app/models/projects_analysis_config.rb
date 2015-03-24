class  ProjectsAnalysisConfig < ActiveRecord::Base
  belongs_to :project
  belongs_to :analysis_config

  has_many :projects_analysis_config_items, dependent: :destroy
  has_many :analysis_config_items, through: :projects_analysis_configs

  has_many :build_items, dependent: :destroy

  accepts_nested_attributes_for :projects_analysis_config_items

  scope :enabled, -> { where(enabled: true) }

  validates :analysis_config, presence: true, uniqueness: { scope: :project_id }

  def full_config
    global_config = project.global_config
    global_config['AllCops']['RunRailsCops'] = run_rails_cops?

    global_config.merge(config)
  end

  def config
    { analysis_config.name => configs }
  end

  def configs
    projects_analysis_config_items.inject({}) do |hash, projects_analysis_config_item|
      hash[projects_analysis_config_item.analysis_config_item.name] = projects_analysis_config_item.value
      hash
    end
  end

  private

  def run_rails_cops?
    analysis_config.cop_class.rails?
  end
end
