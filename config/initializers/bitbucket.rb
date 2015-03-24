Bitbucket.configure do |config|
  config.client_id = ENV['bitbucket_key']
  config.client_secret = ENV['bitbucket_secret']
end
