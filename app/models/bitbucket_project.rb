class BitbucketProject < Project
  def self.import(user)
    user.bitbucket_client.repositories.map do |repo|
      BitbucketProject.new BitbucketProject.attributes_from(repo, user)
    end
  end

  def self.attributes_from(repo, user)
    {
      name: "#{repo['owner']}/#{repo['name']}",
      private: repo['is_private']
    }
  end

  def commit_url(commit_id)
    "https://bitbucket.org/#{self.name}/commits/#{commit_id}"
  end

  def pushable_for?(user)
    unless user.connected_with?(:bitbucket)
      self.errors.add :base, 'You have not connected your Bitbucket account yet.'
    end

    self.errors.blank?
  end

  def support_oauth_cloning?
    false
  end

  def send_pull_request(pull_request)
    owner.bitbucket_client.create_pull_request self.name, {
      title: pull_request.commit_message,
      source_branch: pull_request.source_branch,
      destination_branch: pull_request.destination_branch
    }
  end

  protected

  def ssh_url
    "git@bitbucket.org:#{self.name}.git"
  end

  #
  # Only the repository owner, a team account administrator, or an account with administrative rights on the repository can can query or modify repository privileges
  def valid_repository?
    response = owner.bitbucket_client.privileges self.name, owner.uid(:bitbucket)

    if response == 'None'
      self.errors.add(:base, "You cannot configure this repository. Please contact the administrator to set up the project for you!")
      return false
    end

    true
  end

  def add_hook
    return false if self.hook_id.present?

    hooks = owner.bitbucket_client.services(self.name).find do |item|
      item['type'] == 'POST' && item['service']['fields']['value'] == hook_url
    end

    if hooks.present?
      self.hook_id = hooks.first['id']
    else
      result = owner.bitbucket_client.create_service self.name, hook_url
      self.hook_id = result['id']
    end

    save
  end

  def remove_hook
    return if self.hook_id.blank?

    owner.bitbucket_client.delete_service self.name, self.hook_id
    self.update_attribute :hook_id, nil
  end

  def add_deploy_key
    return if self.deploy_key_id.present?

    deploy_key = owner.bitbucket_client.deploy_keys(self.name).find do |item|
      item['label'] == label_for_deploy_key
    end

    if deploy_key.present?
      self.deploy_key_id = deploy_key['pk']
    else
      result = owner.bitbucket_client.create_deploy_key self.name, generate_ssh_public_key, label_for_deploy_key
      self.deploy_key_id = result['pk']
    end

    save
  end

  def remove_deploy_key
    return if self.deploy_key_id.blank?

    owner.bitbucket_client.delete_deploy_key self.name, self.deploy_key_id
    self.update_attributes deploy_key_id: nil
  end

  def label_for_deploy_key
    'Awesome Code'
  end

  private

  def self.generate_ssh_url(repo)
    "git@bitbucket.org:#{repo['owner']}/#{repo['slug']}.git"
  end
end