# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :analysis_config do
    name "Style/AlignParameters"
    category "Style"
    description "Description"
    guide "Guide"
    enabled false
  end
end
