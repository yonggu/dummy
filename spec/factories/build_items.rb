FactoryGirl.define do
  factory :build_item do
    build
    passed true
    projects_analysis_config
  end

  factory :failed_build_item, class: BuildItem do
    build
    passed false
    projects_analysis_config
  end
end
