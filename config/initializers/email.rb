email_config = YAML.load_file('config/email.yml')[Rails.env]

Mailgun.configure do |config|
  config.api_key = email_config['api_key']
  config.domain  = email_config["domain"]
end

ActionMailer::Base.smtp_settings = email_config.symbolize_keys

if Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
else
  ActionMailer::Base.delivery_method = :letter_opener
end

