require 'rails_helper'

describe ProjectsController do
  let(:user) { create :user }
  let(:project) { create :project, owner: user }

  before do
    sign_in user
  end

  describe "GET index" do
    before do
      get :index
    end

    it { is_expected.to render_template('index') }
  end

  describe "GET show" do
    before do
      get :show, id: project.id
    end

    it { is_expected.to render_template('show') }
  end

  describe "GET #edit" do
    before do
      get :edit, id: project.id
    end

    it { is_expected.to render_template('edit') }
  end

  describe "PUT #update" do
    let(:valid_attributes) { attributes_for(:project) }

    subject { project.send_mail }
    it { is_expected.to be_truthy }

    it "saves hipchat config" do
      put :update, id: project.id, project: { hipchat_config_attributes: { auth_token: '123456', room: 'Xinminlabs' } }
      expect(project.reload.hipchat_config.auth_token).to eq '123456'
      expect(project.reload.hipchat_config.room).to eq 'Xinminlabs'
    end

    it "saves slack config" do
      put :update, id: project.id, project: { slack_config_attributes: { webhook_url: 'https://hooks.slack.com/services/T00000005/B03JSGXJJ/foKGyMZJnKBEN3NL2cf1BMam' } }
      expect(project.reload.slack_config.webhook_url).to eq 'https://hooks.slack.com/services/T00000005/B03JSGXJJ/foKGyMZJnKBEN3NL2cf1BMam'
    end

    context "with valid attributes" do
      before do
        put :update, id: project.id, project: valid_attributes
      end

      it { expect(response).to redirect_to(project_path(project)) }
      it "updates the project successfully" do
        expect(project.reload.name).to eq valid_attributes[:name]
      end
    end

    context "test send_mail change" do
      it "send_mail should be false" do
        put :update, id: project.id, project: { send_mail: 0 }
        expect(project.reload.send_mail).to be_falsey
      end

      it "send_mail should be true" do
        project.update(send_mail: false)
        put :update, id: project.id, project: { send_mail: 1 }
        expect(project.reload.send_mail).to be_truthy
      end
    end
  end
end
