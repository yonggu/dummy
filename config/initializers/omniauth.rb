Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bitbucket, ENV['bitbucket_key'], ENV['bitbucket_secret']
  provider :github, ENV['github_key'], ENV['github_secret'], scope: 'repo,admin:repo_hook'
end
