class PullRequest < ActiveRecord::Base
  include GitHelper

  belongs_to :user
  belongs_to :build_item

  delegate :build, to: :build_item

  validate :validate_project_is_pushable_for_user, on: :create

  def submit
    if self.push_directly
      push_to_remote
    else
      send_pull_request
    end

    if errors.blank?
      update_attributes sent_at: Time.now
    else
      false
    end
  end

  def commit_message
    @commit_message ||= "Auto corrected by following #{build_item.config_key}"
  end

  def source_branch
    @source_branch ||= "awesomecode-#{build_item.config_key}-#{build.id}"
  end

  def destination_branch
    @destination_branch ||= build.branch
  end

  def push_complete_event
    if push_directly?
      pusher_trigger 'complete', message: 'It is already pushed.'
    else
      pusher_trigger 'complete', message: 'Pull request is already created.'
    end
  end

  def push_fail_event
    pusher_trigger 'fail', message: errors.full_messages
  end

  private

  def pusher_trigger(event, params = {})
    Pusher.trigger "private-project-#{build_item.build.project.id}", "pull_request:#{event}", { build_item_id: build_item.id }.merge(params) unless Rails.env.test?
  end

  def push_to_remote
    git_checkout build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch
    RubocopAnalyzer.new(build.repository_path, build_item.analysis_config.cop_class, build_item.projects_analysis_config.full_config).run
    output = git_push build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch, commit_message: commit_message
    unless output[:success]
      self.errors.add :base, 'Can not push to remote'
    end
  end

  def send_pull_request
    git_checkout build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch, source_branch: source_branch
    RubocopAnalyzer.new(build.repository_path, build_item.analysis_config.cop_class, build_item.projects_analysis_config.full_config).run
    output = git_push build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch, source_branch: source_branch,
                                    commit_message: commit_message
    if output[:success]
      build.project.send_pull_request(self)
    else
      self.errors.add :base, 'Can not push to remote'
    end
  end

  def validate_project_is_pushable_for_user
    unless build.project.pushable_for?(user)
      self.errors.set :base, build.project.errors[:base]
    end
  end
end
