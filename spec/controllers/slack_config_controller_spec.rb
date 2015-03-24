require 'rails_helper'

describe Project::SlackConfigsController do
  let(:user) { create :user }
  let(:project) { create :project, owner: user }
  let(:valid_attributes) { attributes_for :slack_config, webhook_url: 'https://hooks.slack.com/services/T00000001/B03JFL0R7/6JKhcjqgw1FidqQ0yP946omK' }
  let(:invalid_attributes) { { webhook_url: '' } }

  before do
    sign_in user
  end

  describe "POST #create" do
    it "create success" do
      put :create, project_id: project.id, slack_config: valid_attributes
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.slack_config.webhook_url).to eq valid_attributes[:webhook_url] 
    end
  end

  describe "PUT #update" do
    let(:slack_config) { create :slack_config, project: project, webhook_url: 'https://hooks.slack.com/services/T00000002/B03JFL0R7/6JKhcjqgw1FidqQ0yP946omK' }

    it "updates successfully" do
      put :update, project_id: project.id, id: slack_config.id, slack_config: valid_attributes
      expect(response).to redirect_to(project_path(project))
      expect(slack_config.reload.webhook_url).to eq valid_attributes[:webhook_url]
    end

    it "destroys slack_config" do
      put :update, project_id: project.id, id: slack_config.id, slack_config: invalid_attributes
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.slack_config).to be_nil
    end
  end
end
