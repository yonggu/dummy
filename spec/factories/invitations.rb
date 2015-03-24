FactoryGirl.define do
  factory :invitation do
    project
    inviter factory: :user
    invitee factory: :user
    email { Faker::Internet.email }
  end
end
