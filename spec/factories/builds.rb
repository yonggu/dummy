# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    started_at { Time.now - 10.minutes }
    finished_at { Time.now - 5.minutes }
    branch Faker::Lorem.word
    last_commit_id Faker::Lorem.characters(40)
    association :project, factory: :github_project
  end
end
