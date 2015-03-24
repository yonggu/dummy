FactoryGirl.define do
  factory :offense do
    severity  Faker::Lorem.word
    message Faker::Lorem.sentence
    corrected false
    line 1
    column 1
    length 1
    build_item
    changed_file
  end
end
