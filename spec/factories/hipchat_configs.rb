# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hipchat_config do
    auth_token Faker::Lorem.characters(16)
    room 'Room'
  end
end
