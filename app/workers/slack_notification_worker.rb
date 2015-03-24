class SlackNotificationWorker
  @queue = :notification

  def self.perform(build_id)
    build = Build.find build_id
    build.project.slack_config.send_notification build_id
  end
end
