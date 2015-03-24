require 'resque/tasks'

# https://gist.github.com/snatchev/1316470
task 'resque:setup' => :environment do
  ENV['QUEUE'] ||= '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
