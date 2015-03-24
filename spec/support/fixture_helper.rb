module FixtureHelper
  def load_rubocop_output
    File.read(Rails.root.join("spec", "fixtures", "rubocop.json"))
  end

  def load_project_config_enabled_params
    File.read(Rails.root.join("spec", "fixtures", "project_config_enabled_params.json"))
  end

  def load_github_org_repos
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "github_org_repos_response.json"))
  end

  def load_github_organizations
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "github_organizations_response.json"))
  end

  def load_github_repositories
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "github_repositories_response.json"))
  end

  def load_github_user
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "github_user_response.json"))
  end

  def load_github_organization
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "github_organization_response.json"))
  end

  def load_bitbucket_user_repositories
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "bitbucket_user_repositories_response.json"))
  end

  def load_bitbucket_user
    JSON.parse File.read(Rails.root.join("spec", "fixtures", "bitbucket_user_response.json"))
  end

  def read_changed_file
    File.read(Rails.root.join("spec", "fixtures", "demo.rb"))
  end
end
