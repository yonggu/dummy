set :rvm_type, :user
set :rvm_ruby_version, '2.2.0'

set :application, 'awesomecode.io'
set :repo_url, 'git@github.com:xinminlabs/awesomecode.io.git'
set :branch, 'develop'
set :deploy_to, '/home/deploy/sites/awesomecode.io/production'
set :scm, :git
set :keep_releases, 5

set :resque_environment_task, true

# Default value for :pty is false
# set :pty, true

set :linked_files, %w{config/application.yml config/database.yml config/secrets.yml config/redis.yml config/email.yml config/newrelic.yml}

set :linked_dirs, %w{bin log builds tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads config/rubocop}

after "deploy:publishing", "puma:restart"
after "deploy:publishing", "resque:restart"

require 'capistrano-db-tasks'

# if you haven't already specified
set :rails_env, "production"

# if you want to remove the local dump file after loading
set :db_local_clean, true

# if you want to remove the dump file from the server after downloading
set :db_remote_clean, true

# If you want to import assets, you can change default asset dir (default = system)
# This directory must be in your shared directory on the server
# set :assets_dir, %w(public/assets public/att)
# set :local_assets_dir, %w(public/assets public/att)

# if you want to work on a specific local environment (default = ENV['RAILS_ENV'] || 'development')
# set :locals_rails_env, "production"

# if you are highly paranoid and want to prevent any push operation to the server
set :disallow_pushing, true

namespace :deploy do
  task :sync_assets do
    on roles(:app) do
      execute "scp -r #{release_path}/public/assets deploy@db.xinminlabs.com:#{release_path}/public/assets"
    end
  end

  before :publishing, :sync_assets
  before :publishing, "rubocop:sync"
end
