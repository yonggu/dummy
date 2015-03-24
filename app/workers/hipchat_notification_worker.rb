class HipchatNotificationWorker
  @queue = :notification

  def self.perform(build_id)
    build = Build.find build_id
    build.project.hipchat_config.send_notification build_id
  end
end
