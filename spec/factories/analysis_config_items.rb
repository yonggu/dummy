# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :analysis_config_item do
    analysis_config
    name "Name"
    value "Value"
  end
end
