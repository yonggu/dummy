require 'rails_helper'

RSpec.describe BuildItem, :type => :model do
  let(:build_item) { create :build_item, passed: nil }
  let(:failed_build_item) { create :failed_build_item, passed: nil }

  describe '#support_autocorrect?' do
    context 'when its AnalysisConfig supports autocorrect' do
      before do
        analysis_config = create :analysis_config, name: RuboCop::Cop::Cop.all.find{|cop| cop.method_defined?(:autocorrect)}.cop_name
        projects_analysis_config = create :projects_analysis_config, analysis_config: analysis_config
        build_item.projects_analysis_config = projects_analysis_config
      end

      it { expect(build_item).to be_support_autocorrect }
    end

    context 'when its AnalysisConfig does not support autocorrect' do
      before do
        analysis_config = create :analysis_config, name: RuboCop::Cop::Cop.all.find{|cop| !cop.method_defined?(:autocorrect)}.cop_name
        projects_analysis_config = create :projects_analysis_config, analysis_config: analysis_config
        build_item.projects_analysis_config = projects_analysis_config
      end

      it { expect(build_item).not_to be_support_autocorrect }
    end
  end

  describe "#already_push_directly?" do
    context "pull request exists with push_directly true" do
      before do
        pull_request = build :pull_request, push_directly: true, build_item: build_item
        pull_request.save(validate: false)
      end

      it { expect(build_item).to be_already_push_directly }
    end

    context "pull request exists with push_directly false" do
      before do
        pull_request = build :pull_request, push_directly: false, build_item: build_item
        pull_request.save(validate: false)
      end

      it { expect(build_item).not_to be_already_push_directly }
    end

    context "pull request doesn't exist" do
      it { expect(build_item).not_to be_already_push_directly }
    end
  end

  describe "#already_pull_request?" do
    context "pull request exists with push_directly true" do
      before do
        pull_request = build :pull_request, push_directly: true, build_item: build_item
        pull_request.save(validate: false)
      end

      it { expect(build_item).not_to be_already_pull_request }
    end

    context "pull request exists with push_directly false" do
      before do
        pull_request = build :pull_request, push_directly: false, build_item: build_item
        pull_request.save(validate: false)
      end

      it { expect(build_item).to be_already_pull_request }
    end

    context "pull request doesn't exist" do
      it { expect(build_item).not_to be_already_pull_request }
    end
  end
end
