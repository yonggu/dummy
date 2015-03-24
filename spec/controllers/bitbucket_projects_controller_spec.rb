require 'rails_helper'

describe BitbucketProjectsController do
  let(:user) { create :user }
  let(:identity) { create :identity, provider: 'bitbucket', user: user }

  before do
    worker = double()
    allow(RubocopAnalysisStatusWorker).to receive(:create) { worker }

    sign_in user
  end

  describe "GET setup_scm" do
    context 'when the user is connected with bitbucket' do
      before do
        identity.save

        get :setup_scm
      end

      it { expect(response).to render_template('setup_scm') }
    end

    context 'when the user is not connected with bitbucket' do
      before do
        get :setup_scm
      end

      it { expect(response).to redirect_to('/auth/bitbucket') }
    end
  end

  describe "POST create" do
    before do
      allow_any_instance_of(Project).to receive(:activate) { true }
    end

    context "when it saved successfully" do
      it "creates a BitbucketProject" do
        expect {
          post :create, project: { name: 'owner/project' }
        }.to change{ BitbucketProject.count }.by(1)
      end

      it 'redirects to select scm page' do
        post :create, project: { name: 'owner/project' }
        expect(response).to redirect_to(project_path(BitbucketProject.last))
      end
    end

    context "when it failed to save" do
      before do
        allow_any_instance_of(BitbucketProject).to receive(:save) { false }
        post :create, project: { name: 'owner/project' }
      end

      it "renders the template 'setup_scm'" do
        expect(response).to render_template('bitbucket_projects/setup_scm')
      end
    end
  end
end

