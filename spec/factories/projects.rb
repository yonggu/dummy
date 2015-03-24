FactoryGirl.define do
  factory :project do
    sequence(:name) {|n| "owner/project_#{n}"}
    included_files []
    excluded_files []
    send_mail true

    after(:build) { |user| user.class.skip_callback(:create, :after, :activate) }
  end

  factory :github_project, class: GithubProject, parent: :project do
  end

  factory :bitbucket_project, class: BitbucketProject, parent: :project do
  end
end
