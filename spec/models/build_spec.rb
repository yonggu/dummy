require 'rails_helper'

RSpec.describe Build, :type => :model do
  let(:project) { create :bitbucket_project, name: 'experiments', git_url: 'https://bitbucket.org/yaonie084/experiments.git', send_mail: true }
  let!(:hipchat_config) { create :hipchat_config, project: project }
  let!(:slack_config) { create :slack_config, project: project }
  let(:build) do
    create :build, started_at: nil,
                   finished_at: nil,
                   aasm_state: :running,
                   branch: 'dummy',
                   author: 'ethan',
                   last_commit_id: '8c5ef22eacd687c12b8827d97406388f37ca246f',
                   last_commit_message: 'aa',
                   project: project
  end
  let(:failed_result) do
    { :files=>[{
        :path=>"bin/rspec",
        :offenses=>[{
          :severity=>:convention,
          :message=>"Align the parameters of a method call if they span more than one line.",
          :cop_name=>"Style/AlignParameters",
          :corrected=>true,
          :location=>{:line=>11, :column=>3, :length=>31}
        }]
      }]
    }
  end
  let(:passed_result) do
    { :files => [] }
  end

  before do
    project.send(:load_global_config_from_yaml)
    project.send(:create_projects_analysis_configs_and_projects_analysis_config_items)
  end

  describe "#do_run" do
    before do
      hipchat_room = double(send: '')
      allow(HipChat::Client).to receive(:new).and_return({"Myroom" => hipchat_room})

      notifier = double(Slack::Notifier)
      allow(Slack::Notifier).to receive(:new).and_return(notifier)

      analyzer = double()
      allow(RubocopAnalyzer).to receive(:new) { analyzer }
      allow(analyzer).to receive(:run).and_return(failed_result)

      allow(build).to receive(:git_clone).with(project.clone_url, build.repository_path, build.last_commit_id, project.ssh_private_key_path)
      allow(build).to receive(:git_diff).and_return(result: 'diff')
      allow(build).to receive(:git_reset).with(build.repository_path, build.last_commit_id)
      allow(build).to receive(:send_hipchat_notification)
      allow(build).to receive(:send_email_notification)
    end

    after do
      if File.exist? build.repository_path
        FileUtils.rm_rf build.repository_path
      end
    end

    it 'clones the repository' do
      expect(build).to receive(:git_clone).with(project.clone_url, build.repository_path, build.last_commit_id, project.ssh_private_key_path)
      build.do_run
    end

    it 'does not clone the repository when it exists' do
      FileUtils.mkdir_p build.repository_path
      expect(build).not_to receive(:git_clone).with(project.clone_url, build.repository_path, build.last_commit_id, project.ssh_private_key_path)
      build.do_run
    end

    context "when it is successful but not recovered" do
      before do
        analyzer = double()
        allow(RubocopAnalyzer).to receive(:new) { analyzer }
        allow(analyzer).to receive(:run).and_return(passed_result)

        allow(build).to receive(:recovered?) { false }
      end

      context "sets attributes" do
        before do
          build.do_run
        end

        it { expect(build.finished_at).to be_present }
        it { expect(build.aasm_state).to eq("completed") }
      end

      it 'sends hipchat notification' do
        expect(build).to receive(:send_hipchat_notification)
        build.do_run
      end

      it 'sends slack notifcation' do
        expect(build).to receive(:send_slack_notification)
        build.do_run
      end

      it 'does not send email notification' do
        expect(build).not_to receive(:send_email_notification)
        build.do_run
      end
    end

    context "when it is recovered" do
      before do
        analyzer = double()
        allow(RubocopAnalyzer).to receive(:new) { analyzer }
        allow(analyzer).to receive(:run).and_return(failed_result)

        allow(build).to receive(:recovered?) { true }
      end

      context "sets attribuets" do
        before do
          build.do_run
        end

        it { expect(build.reload.finished_at).to be_present }
        it { expect(build.reload.aasm_state).to eq("completed") }
      end

      it 'sends hipchat notification' do
        expect(build).to receive(:send_hipchat_notification)
        build.do_run
      end

      it 'sends slack notification' do
        expect(build).to receive(:send_slack_notification)
        build.do_run
      end

      it 'sends email notification' do
        expect(build).to receive(:send_email_notification)
        build.do_run
      end
    end

    context "when it is not successful" do
      context "sets attributes" do
        before do
          build.do_run
        end

        it { expect(build.reload.finished_at).to be_present }
        it { expect(build.reload.aasm_state).to eq("completed") }
        it { expect(build.reload.build_items).to be_present }
        it { expect(build.reload.changed_files).to be_present }
      end

      it 'sends hipchat notification' do
        expect(build).to receive(:send_hipchat_notification)
        build.do_run
      end

      it 'sends slack notification' do
        expect(build).to receive(:send_slack_notification)
        build.do_run
      end

      it 'sends email notification' do
        expect(build).to receive(:send_email_notification)
        build.do_run
      end
    end

    context "when there is an exception" do
      before do
        allow(build).to receive(:complete!).and_raise(ArgumentError)
        build.do_run
      end
      it { expect(build.aasm_state).to eq("failed") }
    end
  end

  describe ".build_from_bitbucket" do
    let(:bitbucket_hook_params) { File.read(Rails.root.join("spec/fixtures/bitbucket_hook_params.json")) }

    it "build a build" do
      json = JSON.parse(bitbucket_hook_params)
      build = Build.build_from_bitbucket(json)
      expect(build).to be_an_instance_of(Build)
      expect(build.author_email).to eq 'ethan@xinminlabs.com'
    end
  end

  describe ".build_from_github" do
    let(:github_hook_params) { File.read(Rails.root.join("spec/fixtures/github_hook_params.json")) }
    it "build a build" do
      json = JSON.parse(github_hook_params)
      build = Build.build_from_github(json)
      expect(build).to be_an_instance_of(Build)
      expect(build.author_email).to eq 'ethan@xinminlabs.com'
    end
  end

  describe "#repository_path" do
    let(:project) { create :github_project, name: "Test Project" }
    let(:build) { create :build, project: project, last_commit_id: '123456' }
    subject { build.repository_path }
    it { is_expected.to eq(Rails.root.join("builds", "repositories", "Test Project", '123456').to_s) }
  end

  describe "#recovered?" do
    let(:project) { create :bitbucket_project }
    let(:build) { create :build, project: project, aasm_state: :completed }

    [:pending, :running, :failed].each do |state|
      it "returns false when it is #{state}" do
        build.update_attributes aasm_state: state
        expect(build.recovered?).to be_falsey
      end
    end

    context "when the project does not have previous build" do
      it { expect(build.recovered?).to be_falsey }
    end

    context "when the project has a successful previous build" do
      before do
        analyzer = double()
        allow(RubocopAnalyzer).to receive(:new) { analyzer }
        allow(analyzer).to receive(:run).and_return(failed_result)
      end

      context "when the last build is successful" do
        let(:last_build) { create :build, project: project, aasm_state: :completed, success: true }
        it { expect(last_build.recovered?).to be_falsey }
      end
      context "when the last build is failed" do
        let(:last_build) { create :build, project: project, aasm_state: :completed, success: false}
        it { expect(last_build.recovered?).to be_falsey }
      end
    end

    context "when the project has a failed previous build" do
      before do
        build.update_attributes aasm_state: :completed, success: false
      end

      context "when the last build is successful" do
        let(:last_build) { create :build, project: project, aasm_state: :completed, success: true }
        it { expect(last_build.recovered?).to be_truthy }
      end
      context "when the last build is failed" do
        let(:last_build) { create :build, project: project, aasm_state: :completed, success: false }
        it { expect(last_build.recovered?).to be_falsey }
      end
    end
  end

  describe '#sorted_build_items' do
    before do
      @passed_build_item = create :build_item, build: build, passed: true

      @failed_build_item_with_autocorrect = create :build_item, build: build
      @failed_build_item_with_autocorrect.update_attributes passed: false
      allow(@failed_build_item_without_autocorrect).to receive(:support_autocorrect?) { true }

      @failed_build_item_without_autocorrect = create :build_item, build: build, passed: false
      @failed_build_item_without_autocorrect.update_attributes passed: false
      allow(@failed_build_item_without_autocorrect).to receive(:support_autocorrect?) { false }
    end

    it { expect(build.sorted_build_items).to eq [@failed_build_item_with_autocorrect, @failed_build_item_without_autocorrect, @passed_build_item] }
  end

  describe '#duration' do
    let(:time) { Time.now }
    let(:build) { create :build, started_at: time, finished_at: time + 2.minutes + 10.seconds }

    it { expect(build.duration).to eq 130.0 }

    it 'returns nil if started_at is nil' do
      build.started_at = nil

      expect(build.duration).to be_nil
    end

    it 'returns nil if finished_at is nil' do
      build.finished_at = nil

      expect(build.duration).to be_nil
    end
  end

  describe '#duration_words' do
    let(:time) { Time.now }
    let(:build) { create :build, started_at: time, finished_at: time + 2.minutes + 10.seconds }

    it { expect(build.duration_to_words).to eq "2 min 10 sec" }

    it 'returns nil if started_at is nil' do
      build.started_at = nil

      expect(build.duration_to_words).to be_nil
    end

    it 'returns nil if finished_at is nil' do
      build.finished_at = nil

      expect(build.duration_to_words).to be_nil
    end
  end

  describe '#start!' do
    before do
      ResqueSpec.reset!
      build.start!
    end

    it { expect(RubocopAnalysisStatusWorker).to have_queue_size_of(1) }
    it { expect(build.job_id).to be_present }
    it { expect(build).to be_running }
  end

  describe '#rebuild!' do
    before do
      build.update_attributes aasm_state: :completed
      ResqueSpec.reset!
      build.rebuild!
    end

    it { expect(RubocopAnalysisStatusWorker).to have_queue_size_of(1) }
    it { expect(build.job_id).to be_present }
    it { expect(build).to be_pending }
  end
end
