class AnalysisConfig < ActiveRecord::Base
  has_many :projects_analysis_configs, dependent: :destroy
  has_many :analysis_config_items, dependent: :destroy
  accepts_nested_attributes_for :analysis_config_items

  validates :name, :category, presence: true

  def support_autocorrect?
    cop_class && (cop_class.public_method_defined?(:autocorrect) || cop_class.protected_method_defined?(:autocorrect) || cop_class.private_method_defined?(:autocorrect))
  end

  def cop_class
    @cop_class ||= $cops_hash[self.name]
  end

  def self.latest_version
    Rails.root.join('config', 'rubocop').children.select(&:directory?).map{|pathname| pathname.basename.to_s}.max
  end

  def self.set_version(version = AnalysisConfig.latest_version)
    return unless File.exists?(Rails.root.join('config', 'rubocop', version))

    sync version
    sync_analysis_config_items version
  end

  def self.sync(version)
    configs = {}
    %w(enabled.yml disabled.yml).each do |yml|
      configs.merge! YAML.load_file(Rails.root.join('config', 'rubocop', version, yml))
    end

    AnalysisConfig.all.reject{ |analysis_config| configs.keys.include?(analysis_config.name) }.each(&:destroy)

    configs.each do |key, value|
      analysis_config = AnalysisConfig.find_or_initialize_by(name: key)
      analysis_config.assign_attributes category: key.split('/').first, description: value['Description'], guide: value['StyleGuide'], enabled: value['Enabled']
      analysis_config.save

      Project.all.each do |project|
        projects_analysis_config = project.projects_analysis_configs.create analysis_config: analysis_config, enabled: analysis_config.enabled
        project.create_projects_analysis_config_items(projects_analysis_config) if projects_analysis_config.persisted?
      end
    end
  end

  def self.sync_analysis_config_items(version)
    configs = YAML.load_file(Rails.root.join('config', 'rubocop', version, 'default.yml'))
    configs.each do |key, value|
      next if key == 'inherit_from' || key == 'AllCops'

      analysis_config = AnalysisConfig.find_by(name: key)
      value.each do |analysis_config_item_key, analysis_config_item_value|
        next if analysis_config_item_key.start_with?('Supported')

        analysis_config_item = analysis_config.analysis_config_items.build(name: analysis_config_item_key, value: analysis_config_item_value)
        if analysis_config_item_key.start_with?('Enforced')
          supported = analysis_config_item_key.sub('Enforced', 'Supported').pluralize
          analysis_config_item.options = value[supported]
        end

        analysis_config_item.save
      end
    end
  end
end
