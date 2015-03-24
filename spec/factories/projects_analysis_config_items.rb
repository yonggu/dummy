# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projects_analysis_config_item do
    projects_analysis_config
    analysis_config_item
    value "Value"
  end
end
