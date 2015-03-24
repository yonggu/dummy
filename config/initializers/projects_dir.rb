if Rails.env.test?
  $projects_dir = "target_projects_test"
else
  $projects_dir = "target_projects"
end