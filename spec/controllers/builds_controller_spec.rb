require 'rails_helper'

describe BuildsController do
  let(:user) { create :user }
  let(:project) { create :github_project, owner: user }
  let(:build) { create :build, project: project }

  before do
    sign_in user
  end

  describe "POST #create" do
    it "with valid attributes" do
      post :create, project_id: project.id, payload: File.read(Rails.root.join("spec/fixtures/bitbucket_hook_params.txt"))
      expect(project.builds.count).to eq 1
    end
  end

  describe "GET #show" do
    before { get :show, project_id: project.id, id: build.id }

    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('show') }
  end

  describe "PUT #rebuild" do before do
      allow(RubocopAnalysisStatusWorker).to receive(:create).with(build_id: build.id) { 1 }
      put :rebuild, project_id: project.id, id: build.id, format: :json
    end

    it { is_expected.to respond_with(200) }
  end

  describe "PUT #stop" do
    before do
      allow(RubocopAnalysisStatusWorker).to receive(:create).with(build_id: build.id) { 1 }
      put :rebuild, project_id: project.id, id: build.id, format: :json
    end

    it { is_expected.to respond_with(200) }
  end
end
