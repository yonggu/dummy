class SlackConfig < ActiveRecord::Base
  belongs_to :project

  validates :webhook_url, presence: true, uniqueness: true

  def send_notification(build_id)
    build = Build.find(build_id)
    notifier.ping '', username: 'Awesome Code', attachments: attachments(build)
  end

  private

  def notifier
    @notifier ||= Slack::Notifier.new webhook_url
  end

  def message(build)
    if build.success?
      "<#{build.absolute_url}|Build succeeded> for branch on <#{project.absolute_url}|#{project.name}> (#{commit_link(build.last_commit_id)})"
    else
      "There seems to be a problem on branch #{build.branch} for <#{project.absolute_url}|#{project.name}>.\nMessage: #{build.last_commit_message} (#{commit_link(build.last_commit_id)})"
    end
  end

  def commit_link(commit_id)
    "<#{project.commit_url(commit_id)}|#{commit_id.first(5)}>"
  end

  def attachments(build)
    [{
      fallback: message(build),
      color: build.success? ? '#7CD197' : '#F35A00',
      fields: [
        {
          title: build.success? ? 'Build succeeded' : 'Build failed',
          value: "<#{build.absolute_url}|#{build.last_commit_message}>",
          short: true
        },
        {
          title: 'Committer',
          value: build.author,
          short: true
        },
        {
          title: 'Branch',
          value: build.branch,
          short: true
        },
        {
          title: 'Project',
          value: project.name,
          short: true
        }
      ]
    }]
  end
end
