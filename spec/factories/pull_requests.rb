# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pull_request do
    user
    sent_at Time.now
    build_item
    push_directly false
  end
end
