class PullRequestWorker
  @queue = :pull_request

  def self.perform(pull_request_id)
    pull_request = PullRequest.find pull_request_id
    if pull_request.submit
      pull_request.push_complete_event
    else
      pull_request.push_fail_event
    end
  end
end
