class GithubProject < Project
  def self.import(user)
    projects = user.github_client.repositories.map do |repo|
      GithubProject.new GithubProject.attributes_from(repo, user)
    end

    projects += user.github_client.organizations.flat_map do |org|
      response = user.github_client.user(org['login'])
      user.github_client.org_repos(org['login']).map do |repo|
        GithubProject.new GithubProject.attributes_from(repo, user)
      end
    end

    projects
  end

  def self.attributes_from(repo, user)
    {
      name: "#{repo[:owner][:login]}/#{repo[:name]}",
      private: repo[:private]
    }
  end

  def commit_url(commit_id)
    "https://github.com/#{name}/commit/#{commit_id}"
  end

  def pushable_for?(user)
    unless user.connected_with?(:github)
      errors.add :base, 'You have not connected your Github account yet.'
    end

    errors.blank?
  end

  def support_oauth_cloning?
    true
  end

  def send_pull_request(pull_request)
    pull_request.user.github_client.create_pull_request name, pull_request.destination_branch, pull_request.source_branch,
                                                        pull_request.commit_message, pull_request.commit_message
  end

  protected

  def ssh_url
    "git@github.com:#{name}.git"
  end

  def oauth_cloning_url
    "https://#{owner.access_token(:github)}:x-oauth-basic@github.com/#{name}.git"
  end

  def valid_repository?
    result = owner.github_client.repository(name)

    unless result[:permissions][:admin]
      errors.add(:base, "You cannot configure this repository. Please contact the administrator to set up the project for you!")
      return false
    end

    true
  end

  def add_hook
    return false if hook_id.present?

    hook = owner.github_client.hooks(name).find do |item|
      item[:config][:url] == hook_url
    end

    if hook.present?
      self.hook_id = hook[:id]
    else
      result = owner.github_client.create_hook(name, 'web', url: hook_url, content_type: :json)
      self.hook_id = result[:id]
    end

    save
  end

  def remove_hook
    return if hook_id.blank?

    owner.github_client.remove_hook "#{name}", hook_id
    update_attribute :hook_id, nil
  end

end
