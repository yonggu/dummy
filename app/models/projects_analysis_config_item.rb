class ProjectsAnalysisConfigItem < ActiveRecord::Base
  serialize :value

  belongs_to :projects_analysis_config
  belongs_to :analysis_config_item

  validates :analysis_config_item, presence: true

  before_save :normalize_value

  private

    def normalize_value
      if analysis_config_item.value.is_a?(Array) && !value.is_a?(Array)
        self.value = value.split(",")
      elsif [TrueClass, FalseClass].include?(analysis_config_item.value.class)
        value == 'true'
      end

      true
    end
end
