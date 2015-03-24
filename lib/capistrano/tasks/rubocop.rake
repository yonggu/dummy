namespace :rubocop do
  desc 'Sync Rubocop'
  task :sync do
    on roles(:app) do
      within "#{release_path}" do
        with rails_env: :production do
          execute :rake, "rubocop:sync"
        end
      end
    end
  end
end
