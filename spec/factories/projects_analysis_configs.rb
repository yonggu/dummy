# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projects_analysis_config do
    project
    analysis_config
    enabled false
  end
end
