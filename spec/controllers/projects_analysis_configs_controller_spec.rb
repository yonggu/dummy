require 'rails_helper'

describe ProjectsAnalysisConfigsController do
  let(:user) { create :user }
  let(:project) { create :project, owner: user }
  let(:projects_analysis_config) { create :projects_analysis_config, project: project }

  before do
    sign_in user
  end

  describe "PUT #toggle" do
    context "when it is enabled" do
      before do
        projects_analysis_config.enabled = false
        projects_analysis_config.save

        put :toggle, id: projects_analysis_config.id, format: :json
      end

      it { expect(projects_analysis_config.reload.enabled).to eq(true) }
      it { expect(response.body).to be_blank }
    end

    context "when it is not enabled" do
      before do
        projects_analysis_config.enabled = true
        projects_analysis_config.save

        put :toggle, id: projects_analysis_config.id, format: :json
      end

      it { expect(projects_analysis_config.reload.enabled).to eq(false) }
      it { expect(response.body).to be_blank }
    end
  end
end

