# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :changed_file do
    path "path"
    original_content "Original Content"
    corrected_content "Corrected Content"
    diff "Diff"
    build_item
  end
end
