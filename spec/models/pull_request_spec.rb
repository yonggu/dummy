require 'rails_helper'

RSpec.describe PullRequest, :type => :model do
  let(:user) { create :user }
  let!(:identity) { create :identity, provider: 'github', user: user }
  let(:analysis_config) { create :analysis_config, name: 'Rails/Validation' }
  let(:project) { create :github_project }
  let!(:membership) { create :membership, project: project, user: user, role: :owner }
  let(:projects_analysis_config) { create :projects_analysis_config, analysis_config: analysis_config }
  let(:build) { create :build, branch: 'dummy', project: project }
  let(:build_item) { create :build_item, build: build, projects_analysis_config: projects_analysis_config }
  let(:pull_request) { create :pull_request, build_item: build_item, user: user, sent_at: nil }

  describe '#submit' do
    let(:analyzer) { double() }
    before do
      allow(pull_request).to receive(:git_checkout)
      allow(RubocopAnalyzer).to receive(:new) { analyzer }
      allow(analyzer).to receive(:run)
      allow(pull_request).to receive(:git_push).and_return({ result: 'result', success: true })

      @github_client = double()
      allow(@github_client).to receive(:create_pull_request)
      allow(user).to receive(:github_client).and_return(@github_client)
    end

    context 'when it is going to push directly' do
      let(:pull_request) { create :pull_request, build_item: build_item, user: user, push_directly: true, sent_at: nil }

      it 'runs git checkout' do
        expect(pull_request).to receive(:git_checkout).with build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch
        pull_request.submit
      end

      it 'runs analyzer' do
        expect(analyzer).to receive(:run)
        pull_request.submit
      end

      it 'runs git push' do
        expect(pull_request).to receive(:git_push).and_return({ result: 'result', success: true })
        pull_request.submit
      end

      context 'when git push returns failed result' do
        before do
          allow(pull_request).to receive(:git_push).and_return({ result: 'result', success: false })
        end

        it 'does not set sent_at' do
          pull_request.submit
          expect(pull_request.sent_at).to be_nil
        end

        it 'adds errors to base' do
          pull_request.submit
          expect(pull_request.errors[:base]).to eq ['Can not push to remote']
        end
      end

      context 'when git push returns successful result' do
        it 'sets sent_at' do
          pull_request.submit
          expect(pull_request.sent_at).not_to be_nil
        end
      end
    end

    context 'when it is going to send pull request' do
      let(:pull_request) { create :pull_request, build_item: build_item, user: user, push_directly: false, sent_at: nil }

      it 'runs git checkout' do
        expect(pull_request).to receive(:git_checkout).with build.repository_path, commit_id: build.last_commit_id, base_branch: build.branch, source_branch: pull_request.source_branch
        pull_request.submit
      end

      it 'runs analyzer' do
        expect(analyzer).to receive(:run)
        pull_request.submit
      end

      it 'runs git push' do
        expect(pull_request).to receive(:git_push).and_return({ result: 'result', success: true })
        pull_request.submit
      end

      context 'when git push returns failed result' do
        before do
          allow(pull_request).to receive(:git_push).and_return({ result: 'result', success: false })
        end

        it 'does not set sent_at' do
          pull_request.submit
          expect(pull_request.sent_at).to be_nil
        end

        it 'does not send pull request' do
          expect_any_instance_of(Octokit::Client).not_to receive(:create_pull_request)
          pull_request.submit
        end

        it 'adds errors to base' do
          pull_request.submit
          expect(pull_request.errors[:base]).to eq ['Can not push to remote']
        end
      end

      context 'when git push returns successful result' do
        it 'sets sent_at' do
          pull_request.submit
          expect(pull_request.sent_at).not_to be_nil
        end

        it 'sends pull request' do
          expect(@github_client).to receive(:create_pull_request)
          pull_request.submit
        end
      end
    end
  end

  describe '#validate_project_is_pushable_for_user' do
    subject { PullRequest.create build_item: build_item, user: user }

    context 'when the project is pusheable for the user' do
      it { expect(subject).to be_valid }
    end

    context 'when the project is not pushable for the user' do
      before do
        pull_request.touch
        user.identities.delete_all
      end

      it { expect(subject).not_to be_valid }
      it { expect(subject.errors[:base]).to eq ['You have not connected your Github account yet.'] }
    end
  end

  describe "#commit_message" do
    it { expect(pull_request.commit_message).to eq 'Auto corrected by following Rails/Validation' }
  end

  describe "#source_branch" do
    it { expect(pull_request.source_branch).to eq "awesomecode-Rails/Validation-#{build.id}" }
  end

  describe "#destination_branch" do
    it { expect(pull_request.destination_branch).to eq 'dummy' }
  end
end
