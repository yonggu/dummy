class BuildFinishedEmailWorker
  @queue = :email

  def self.perform(build_id)
    Notifier.build_finished_email build_id
  end
end
