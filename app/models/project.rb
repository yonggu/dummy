class Project < ActiveRecord::Base
  serialize :included_files, Array
  serialize :excluded_files, Array

  has_many :builds, dependent: :destroy
  has_one :hipchat_config, dependent: :destroy
  accepts_nested_attributes_for :hipchat_config, reject_if: :all_blank

  has_one :slack_config, dependent: :destroy
  accepts_nested_attributes_for :slack_config, reject_if: :all_blank

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :projects_analysis_configs, dependent: :destroy
  has_many :analysis_configs, through: :projects_analysis_configs

  has_many :invitations, dependent: :destroy

  scope :by_type, ->(type) { where(type: type) }

  validates :name, presence: true
  validate :validate_name_must_be_uniq, on: :create

  before_save :normalize_included_files_and_excluded_files
  before_destroy :remove_scm
  after_create :activate

  REPOSITORIES = Rails.root.join("builds", "repositories")
  KEYS_DIRECTORY = Rails.root.join("builds", "keys")

  def self.import(user)
    raise NotImplementedError
  end

  def self.attributes_from(repo, user)
    raise NotImplementedError
  end

  def last_build
    builds.first
  end

  def previous_build
    builds.second
  end

  def clone_url
    if support_oauth_cloning?
      oauth_cloning_url
    else
      ssh_url
    end
  end

  def ssh_url
    raise NotImplementedError
  end

  def oauth_cloning_url
    raise NotImplementedError
  end

  def commit_url(commit_id)
    raise NotImplementedError
  end

  def pushable_for?(user)
    raise NotImplementedError
  end

  def repository_path
    Rails.root.join(REPOSITORIES, name)
  end

  def check_and_send_notifications(users, msg, color)
    hipchat_config.send_notification(msg, color) if hipchat_config.present?
    ProjectMailer.send_notification(users, msg).deliver
  end

  def absolute_url
    "#{Figaro.env.domain_url}/projects/#{id}"
  end

  def activate
    unless setup_scm
      raise ActiveRecord::RecordInvalid.new(self)
      return false
    end

    load_global_config_from_yaml
    create_projects_analysis_configs_and_projects_analysis_config_items

    save
  end

  def setup_scm
    unless valid_repository?
      return false
    end

    add_deploy_key unless support_oauth_cloning?
    add_hook
  end

  def remove_scm
    unless valid_repository?
      return false
    end

    remove_deploy_key unless support_oauth_cloning?
    remove_hook
  end

  def global_config
    hash = {
      'inherit_from' => ['enabled.yml', 'disabled.yml']
    }

    hash['AllCops'] = {
      'Include' => included_files,
      'Exclude' => excluded_files
    }

    hash
  end

  def enabled_configs
    projects_analysis_configs.enabled.inject(Hash.new({})) do |hash, projects_analysis_config|
      hash[projects_analysis_config.analysis_config.name] = {}
      projects_analysis_config.projects_analysis_config_items.each do |projects_analysis_config_item|
        hash[projects_analysis_config.analysis_config.name][projects_analysis_config_item.analysis_config_item.name] = projects_analysis_config_item.value
      end
      hash
    end
  end

  def create_projects_analysis_configs
    projects_analysis_configs = AnalysisConfig.all.map do |analysis_config|
      self.projects_analysis_configs.build analysis_config: analysis_config, enabled: analysis_config.enabled
    end
    ProjectsAnalysisConfig.import projects_analysis_configs

    self.projects_analysis_configs.reload.each do |projects_analysis_config|
      create_projects_analysis_config_items(projects_analysis_config)
    end
  end

  def create_projects_analysis_config_items(projects_analysis_config)
    projects_analysis_config_items = projects_analysis_config.analysis_config.analysis_config_items.map do |analysis_config_item|
      projects_analysis_config.projects_analysis_config_items.build analysis_config_item: analysis_config_item, value: analysis_config_item.value
    end
    ProjectsAnalysisConfigItem.import projects_analysis_config_items
  end

  def owner
    @owner ||= memberships.owner.first.user
  end

  def members
    memberships.map(&:user)
  end

  def owner=(user)
    memberships.build user: user, role: :owner
  end

  def support_oauth_cloning?
    raise NotImplementedError
  end

  def send_pull_request(pull_request)
    raise NotImplementedError
  end

  def generate_ssh_public_key
    ssh_key = SSHKey.generate(comment: "Awesome Code/#{name}")

    write_to_file ssh_private_key_filename, ssh_key.private_key
    write_to_file ssh_public_key_filename, ssh_key.ssh_public_key, 0644

    ssh_key.ssh_public_key
  end

  def ssh_private_key_path
    File.join(KEYS_DIRECTORY, ssh_private_key_filename)
  end

  def grouped_projects_analysis_configs
    projects_analysis_configs.includes(:analysis_config, projects_analysis_config_items: [:analysis_config_item]).group_by{ |projects_analysis_config| projects_analysis_config.analysis_config.category }
  end

  def as_json(options = {})
    super(options).merge(type: type)
  end

  protected

  def valid_repository?
    raise NotImplementedError
  end

  def add_hook
    raise NotImplementedError
  end

  def remove_hook
    raise NotImplementedError
  end

  def add_deploy_key
    raise NotImplementedError
  end

  def remove_deploy_key
    raise NotImplementedError
  end

  def hook_url
    @hook_url ||= Figaro.env.hook_url.sub 'project_id', id.to_s
  end

  def ssh_url
    raise NotImplementedError
  end

  def oauth_cloning_url
    raise NotImplementedError
  end

  private

  def load_global_config_from_yaml
    return true unless AnalysisConfig.latest_version

    config = YAML.load_file(Rails.root.join('config', 'rubocop', AnalysisConfig.latest_version, 'default.yml'))
    assign_attributes included_files: config['AllCops']['Include'], excluded_files: config['AllCops']['Exclude']

    save
  end

  def normalize_included_files_and_excluded_files
    if included_files && !included_files.is_a?(Array)
      self.included_files = included_files.split(",")
    end

    if excluded_files && !excluded_files.is_a?(Array)
      self.excluded_files = excluded_files.split(",")
    end
  end

  def create_projects_analysis_configs_and_projects_analysis_config_items
    projects_analysis_configs = AnalysisConfig.all.map do |analysis_config|
      self.projects_analysis_configs.build analysis_config: analysis_config, enabled: analysis_config.enabled
    end
    ProjectsAnalysisConfig.import projects_analysis_configs

    projects_analysis_config_items = self.projects_analysis_configs.reload.map do |projects_analysis_config|
      projects_analysis_config.analysis_config.analysis_config_items.map do |analysis_config_item|
        projects_analysis_config.projects_analysis_config_items.build analysis_config_item: analysis_config_item, value: analysis_config_item.value
      end
    end.flatten
    ProjectsAnalysisConfigItem.import projects_analysis_config_items
  end

  def validate_name_must_be_uniq
    project = Project.where(type: type, name: name).first
    errors.add :name, "This repository is already set up. Please ask the project owner #{project.owner.name} (#{project.owner.email}) to invite you!" if project
  end

  def ssh_private_key_filename
    ssh_key_prefix + "_rsa"
  end

  def ssh_public_key_filename
    ssh_key_prefix + "_rsa.pub"
  end

  def ssh_key_prefix
    "csg-#{id}"
  end

  def write_to_file(filename, content, perm = 0600)
    file = File.new(File.join(KEYS_DIRECTORY, filename), 'w', perm)
    file.write(content)
    file.close
  end
end
