# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identity do
    uid Faker::Internet.user_name
    provider "bitbucket"
    access_token Faker::Lorem.characters(18)
    access_token_secret Faker::Lorem.characters(32)
    user
  end
end
