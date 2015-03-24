require 'analyzers/rubocop_analyzer'

class Build < ActiveRecord::Base
  include GitHelper

  belongs_to :project
  has_many :build_items, dependent: :destroy
  has_many :changed_files, through: :build_items

  validates :branch, presence: true
  validates :last_commit_id, presence: true

  default_scope -> { order "id DESC" }

  include AASM
  aasm do
    state :pending, initial: true
    state :running
    state :completed
    state :failed
    state :stopped

    event :run, success: [:set_started_at, :push_start_event], after_commit: :do_run do
      transitions from: [:pending, :completed, :failed, :stopped], to: :running
    end

    event :complete, success: [:push_complete_event], after_commit: [:set_success, :send_notifications] do
      transitions from: :running, to: :completed
    end

    event :fail, success: [:push_fail_event] do
      transitions from: :running, to: :failed
    end

    event :stop, success: [:push_stop_event], before: :do_stop do
      transitions from: :running, to: :stopped
    end
  end

  after_create :push_add_event

  def start!
    job_id = RubocopAnalysisStatusWorker.create build_id: self.id
    self.update_attributes job_id: job_id

    job_id
  end

  def rebuild!
    self.update_attributes aasm_state: :pending

    push_pend_event

    start!
  end

  def do_stop
    Resque::Plugins::Status::Hash.kill job_id
  end

  def do_run
    begin
      unless File.exist? repository_path
        FileUtils.mkdir_p repository_path
        git_clone project.clone_url, repository_path, self.last_commit_id, project.ssh_private_key_path
      end

      self.build_items.destroy_all

      project.projects_analysis_configs.enabled.each do |projects_analysis_config|
        result = RubocopAnalyzer.new(repository_path, projects_analysis_config.analysis_config.cop_class, projects_analysis_config.full_config).run

        build_item = build_items.build projects_analysis_config: projects_analysis_config
        result[:files].each do |file|
          diff = git_diff(repository_path, absolute_path(file[:path]))[:result]
          changed_file = build_item.changed_files.build path: file[:path], diff: diff
          file[:offenses].each do |offense|
            changed_file.offenses.build build_item: build_item, severity:  offense[:severity], message: offense[:message], corrected: offense[:corrected],
                                        line: offense[:location][:line], column: offense[:location][:column], length: offense[:location][:length]
          end
        end
        build_item.passed = build_item.changed_files.blank?
        build_item.save

        git_reset repository_path, self.last_commit_id
      end

      complete!
    rescue => e
      Rollbar.error e
      fail!
    ensure
      update_attributes finished_at: Time.now
    end
  end

  def absolute_path(path)
    File.join repository_path, path
  end

  def recovered?
    return false if !completed? || project.previous_build.blank?

    !project.previous_build.success? && success?
  end

  def repository_path
    Rails.root.join(project.repository_path, self.last_commit_id).to_s
  end

  def absolute_url
    "#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{id}"
  end

  def author_avatar_url
    Gravatar.new(author_email).image_url(secure: true)
  end

  def sorted_build_items
    build_items.includes(:analysis_config, changed_files: [:offenses]).group_by(&:passed).values.reverse.each do |items|
      items.sort_by!{ |build_item| build_item.support_autocorrect? ? 0 : 1 }
    end.flatten
  end

  def duration
    return nil if self.started_at.nil? || self.finished_at.nil?

    @duration ||= self.finished_at - self.started_at
  end

  def duration_to_words
    return nil unless duration

    "#{duration.to_i/60} min #{duration.to_i%60} sec"
  end

  def self.build_from_bitbucket(json)
    self.new do |build|
      build.branch = json['commits'].last['branch']
      build.last_commit_id = json['commits'].last['raw_node']
      build.author = json['commits'].last['author']
      build.author_email = Build.match_author_email(json['commits'].last['raw_author'])
      build.last_commit_message = json['commits'].last['message']
    end
  end

  def self.build_from_github(json)
    commit = json['commits'].try(:last) || json['head_commit']
    if commit
      self.new do |build|
        build.branch = json['ref'].gsub 'refs/heads/', ''
        build.last_commit_id = commit['id']
        build.author = commit['committer']['name']
        build.author_email = commit['committer']['email']
        build.last_commit_message = commit['message']
      end
    else
      Build.new
    end
  end

  def self.match_author_email(str)
    /<.*>/.match(str).to_s[1..-2]
  end

  def as_json(options = {})
    super(options).merge(project: project.as_json)
  end

  private

  def push_add_event
    pusher_trigger 'add', { message: 'It is added', build: self }
  end

  def push_start_event
    pusher_trigger 'start', { message: 'It is started', build: self }
  end

  def push_complete_event
    pusher_trigger 'complete', { message: 'It is completed', build: self }
  end

  def push_fail_event
    pusher_trigger 'fail', { message: 'It is failed', build: self }
  end

  def push_stop_event
    pusher_trigger 'stop', { message: 'It is stopped', build: self }
  end

  def push_pend_event
    pusher_trigger 'pend', { message: 'It is pending', build: self }
  end

  def pusher_trigger(event, params = {})
    Pusher.trigger("private-project-#{project.id}", "build:#{event}", { id: self.id }.merge(params)) unless Rails.env.test?
  end

  def send_notifications
    send_email_notification if send_email_notification?
    send_hipchat_notification if project.hipchat_config
    send_slack_notification if project.slack_config
  end

  def send_email_notification?
    project.send_mail && (!success? || recovered?)
  end

  def send_email_notification
    Resque.enqueue BuildFinishedEmailWorker, self.id
  end

  def send_hipchat_notification
    Resque.enqueue HipchatNotificationWorker, self.id
  end

  def send_slack_notification
    Resque.enqueue SlackNotificationWorker, self.id
  end

  def set_started_at
    update_attributes started_at: Time.now
  end

  def set_success
    self.update_attributes success: completed? && build_items.all?(&:passed?)
  end
end
