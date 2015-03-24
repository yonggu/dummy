class BuildItem < ActiveRecord::Base
  belongs_to :build
  belongs_to :projects_analysis_config
  has_many :changed_files, dependent: :destroy
  has_many :offenses, dependent: :destroy
  has_many :pull_requests, dependent: :destroy

  has_one :analysis_config, through: :projects_analysis_config

  def config_key
    projects_analysis_config.analysis_config.name
  end

  def support_autocorrect?
    projects_analysis_config.analysis_config.support_autocorrect?
  end

  def already_push_directly?
    pull_requests.where(push_directly: true).exists?
  end

  def already_pull_request?
    pull_requests.where(push_directly: false).exists?
  end
end
