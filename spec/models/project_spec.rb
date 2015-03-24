require 'rails_helper'

describe Project do
  let(:user) { create :user, name: 'Yong Gu', email: 'test@test.com' }
  let(:project) { create :github_project, name: "Owner/Test Project" }

  describe "#last_build" do
    subject { project.last_build }

    context "when the project does not have any build" do
      it { is_expected.to be_nil }
    end

    context "when the project has at least one build" do
      let!(:build_1) { create :build, project: project, started_at: Time.now - 10.minutes }
      let!(:build_2) { create :build, project: project, started_at: Time.now }
      it { is_expected.to eq(build_2) }
    end
  end

  describe "#validate_name_must_be_uniq" do
    before  do
      create :membership, user: user, project: project, role: :owner
    end

    subject { GithubProject.create name: project.name }

    it { expect(subject).not_to be_valid }
    it { expect(subject.errors[:name]).to eq ["This repository is already set up. Please ask the project owner Yong Gu (test@test.com) to invite you!"] }
  end

  describe "#global_config" do
    before do
      analysis_config = create :analysis_config, name: 'Style/AlignParameters'
      project.projects_analysis_configs.create analysis_config: analysis_config, enabled: true
    end

    it { expect(project.global_config).to eq ({"inherit_from"=>["enabled.yml", "disabled.yml"], "AllCops"=>{"Include"=>[], "Exclude"=>[]}}) }
  end

  describe "#grouped_projects_analysis_configs" do
    let(:style_analysis_config) { create :analysis_config, name: 'Style/AlignParameters', category: 'Style' }
    let!(:style_projects_analysis_config) { create :projects_analysis_config, project: project, analysis_config: style_analysis_config }
    let(:rails_analysis_config) { create :analysis_config, name: 'Rails/AlignParameters', category: 'Rails' }
    let!(:rails_projects_analysis_config) { create :projects_analysis_config, project: project, analysis_config: rails_analysis_config }

    it { expect(project.grouped_projects_analysis_configs).to eq 'Style' => [style_projects_analysis_config], 'Rails' => [rails_projects_analysis_config] }
  end
end
