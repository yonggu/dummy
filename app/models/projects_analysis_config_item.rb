class ProjectsAnalysisConfigItem < ActiveRecord::Base
  serialize :value

  belongs_to :projects_analysis_config
  belongs_to :analysis_config_item

  validates :analysis_config_item, presence: true

  before_save :normalize_value

  private

    def normalize_value
      if analysis_config_item.value.is_a?(Array) && !self.value.is_a?(Array)
        self.value = self.value.split(",")
      elsif [TrueClass, FalseClass].include?(analysis_config_item.value.class)
        self.value == 'true'
      end

      true
    end
end
