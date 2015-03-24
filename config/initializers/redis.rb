require 'yaml'

redis_config = YAML.load_file('config/redis.yml')[Rails.env]
$redis = Redis.new(url: redis_config['url'], db: redis_config['db'], driver: :hiredis)