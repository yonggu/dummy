require 'rails_helper'

describe Project::HipchatConfigsController do
  let(:user) { create :user }
  let(:project) { create :project, owner: user }

  before do
    sign_in user
  end

  describe "POST #create" do
    it "create success" do
      put :create, project_id: project.id, hipchat_config: {auth_token: '123', room: '123'}
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.hipchat_config.auth_token).to eq '123'
    end
  end

  describe "PUT #update" do
    let(:hipchat_config) { create :hipchat_config, project: project }

    it "updates successfully" do
      put :update, project_id: project.id, id: hipchat_config.id, hipchat_config: {auth_token: '123', room: '123'}
      expect(response).to redirect_to(project_path(project))
      expect(hipchat_config.reload.auth_token).to eq '123'
    end

    it "destroys hipchat_config" do
      hipchat_config.update(auth_token: '123', room: '123')
      put :update, project_id: project.id, id: hipchat_config.id, hipchat_config: {auth_token: '', room: ''}
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.hipchat_config).to be_nil
    end
  end
end
