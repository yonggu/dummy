require 'rails_helper'

describe PullRequestsController do
  let(:user) { create :user }
  let(:build_item) { create :build_item }

  describe "POST #create" do
    before do
      allow_any_instance_of(PullRequest).to receive(:submit)
      sign_in(user)

      post :create, build_item_id: build_item.id
    end

    it { expect(response).to redirect_to(project_build_path(build_item.build.project, build_item.build)) }
  end

end
