class HipchatConfig < ActiveRecord::Base
  belongs_to :project

  validates :auth_token, presence: true
  validates :room, presence: true

  def send_notification(build_id)
    build = Build.find(build_id)
    client[room].send('Awesome Code', message(build), color: color(build), notify: true)
  end

  private

  def client
    @client ||= HipChat::Client.new(auth_token)
  end

  def color(build)
    build.success? ? 'green' : 'red'
  end

  def message(build)
    if build.success?
      "<a href='#{build.absolute_url}'> Build succeeded </a> for branch #{build.branch} on <a href='#{project.absolute_url}'>#{project.name}</a> (#{commit_link(build.last_commit_id)})"
    else
      "There seems to be a problem on branch #{build.branch} for <a href='#{project.absolute_url}'>#{project.name}</a>. #{build.author} <a href='#{build.absolute_url}'>should know about it</a><br>Message: #{build.last_commit_message} (#{commit_link(build.last_commit_id)})"
    end
  end

  def commit_link(commit_id)
    "<a href='#{project.commit_url(commit_id)}'>#{commit_id.first(5)}</a>"
  end
end
