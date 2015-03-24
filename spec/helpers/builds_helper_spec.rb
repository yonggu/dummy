require 'rails_helper'

describe BuildsHelper do

  describe "#build_html_class" do
    subject { helper.build_html_class(build) }

    context 'when the build is running' do
      let(:build) { create :build, aasm_state: :running }

      it { expect(subject).to eq :running }
    end

    context 'when the build is successful but not recovered' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: true
        allow(build).to receive(:recovered?) { false }
      end

      it { expect(subject).to eq :success }
    end

    context 'when the build is recovered' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: true
        allow(build).to receive(:recovered?) { true }
      end

      it { expect(subject).to eq :recovered }
    end

    context 'when the build is failed' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: nil
      end

      it { expect(subject).to eq :failed }
    end
  end

  describe "#build_state_tag" do
    subject { helper.build_state_tag(build) }

    context 'when the build is running' do
      let(:build) { create :build, aasm_state: :running }

      it { expect(subject).to eq "<span class=\"label label-info\">RUNNING</span>" }
    end

    context 'when the build is successful but not recovered' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: true
        allow(build).to receive(:recovered?) { false }
      end

      it { expect(subject).to eq "<span class=\"label label-success\">SUCCESS</span>" }
    end

    context 'when the build is recovered' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: true
        allow(build).to receive(:recovered?) { true }
      end

      it { expect(subject).to eq "<span class=\"label label-primary\">RECOVERED</span>" }
    end

    context 'when the build is failed' do
      let(:build) { create :build, aasm_state: :completed }

      before do
        build.update_attributes success: false
      end

      it { expect(subject).to eq "<span class=\"label label-danger\">FAILED</span>" }
    end
  end

  describe "#build_duration" do
    subject { helper.build_duration(build) }

    context 'when the build is running' do
      let(:build) { create :build, aasm_state: :running }

      it { expect(subject).to eq 'Running' }
    end

    context 'when the build is not running' do
      let(:time) { Time.now }
      let(:build) { create :build, aasm_state: :completed, started_at: time, finished_at: time + 2.minutes + 10.seconds }

      it { expect(subject).to eq "Completed in 2 min 10 sec" }
    end
  end

  describe "#build_time_ago" do
    subject { helper.build_time_ago(build) }

    context 'when build finished_at exists' do
      let(:build) { create :build, finished_at: 70.seconds.ago }

      it { expect(subject).to eq "1 minute ago" }
    end

    context 'when build finished_at is nil' do
      let(:build) { create :build, finished_at: nil }

      it { expect(subject).to eq "Not finished yet" }
    end
  end
end
