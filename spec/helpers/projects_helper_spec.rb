require 'rails_helper'

describe ProjectsHelper do
  let(:build) { create :build }

  describe "#project_icon" do
    subject { helper.project_icon(project) }

    context 'when it is a github project' do
      let(:project) { create :github_project }

      it { expect(subject).to eq "<img class=\"project-icon\" src=\"/assets/github-24-black.png\" alt=\"Github 24 black\" />" }
    end

    context 'when it is a bitbucket project' do
      let(:project) { create :bitbucket_project }

      it { expect(subject).to eq "<img class=\"project-icon\" src=\"/assets/bitbucket-24-black.png\" alt=\"Bitbucket 24 black\" />" }
    end
  end
end
