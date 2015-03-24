require 'spec_helper'

describe GitHelper do
  include GitHelper

  let(:project) { double(:project, clone_url: 'git@bitbucket.org:xinminlabs/coding_style_guide.git', ssh_private_key_path: '/home/deploy/rails_apps/coding_stype_guide/builds/keys/csg-1_rsa') }
  let(:build) { double(:build, repository_path: '/home/deploy/rails_apps/coding_stype_guide', last_commit_id: '12345678') }
  let(:path) { 'app/models/bulid.rb' }

  describe '#run_command' do
    let(:command) { 'ls' }

    it 'runs the command' do
      expect(self).to receive(:`).with command
      send :run_command, command
    end

    context 'when it raises exception' do
      let(:exception) { Exception.new }

      before do
        allow(self).to receive(:`).with(command).and_raise(exception)
      end

      it 'sends error to Rollbar' do
        expect(Rollbar).to receive(:error).with(exception, command: 'ls')
        send :run_command, command
      end
    end
  end

  describe '#git_clone' do
    before do
      allow(self).to receive(:run_command).with command
    end

    context 'when ssh private key path is provided' do
      let(:command) { "ssh-agent bash -c 'ssh-add /home/deploy/rails_apps/coding_stype_guide/builds/keys/csg-1_rsa; git clone git@bitbucket.org:xinminlabs/coding_style_guide.git /home/deploy/rails_apps/coding_stype_guide' && cd /home/deploy/rails_apps/coding_stype_guide && git reset --hard 12345678" }

      it 'runs correct command' do
        expect(self).to receive(:run_command).with command
        git_clone project.clone_url, build.repository_path, build.last_commit_id, project.ssh_private_key_path
      end
    end

    context 'when ssh private key path is not provided' do
      let(:command) { 'git clone git@bitbucket.org:xinminlabs/coding_style_guide.git /home/deploy/rails_apps/coding_stype_guide && cd /home/deploy/rails_apps/coding_stype_guide && git reset --hard 12345678' }

      it 'runs correct command' do
        expect(self).to receive(:run_command).with command
        git_clone project.clone_url, build.repository_path, build.last_commit_id
      end
    end
  end

  describe '#git_reset' do
    let(:command) { 'cd /home/deploy/rails_apps/coding_stype_guide && git reset --hard 12345678' }

    before do
      allow(self).to receive(:run_command).with command
    end

    it 'runs correct command' do
      expect(self).to receive(:run_command).with command
      git_reset build.repository_path, build.last_commit_id
    end
  end

  describe '#git_diff' do
    let(:command) { 'cd /home/deploy/rails_apps/coding_stype_guide && git diff app/models/bulid.rb' }

    before do
      allow(self).to receive(:run_command).with command
    end

    it 'runs correct command' do
      expect(self).to receive(:run_command).with command
      git_diff build.repository_path, path
    end
  end

  describe '#git_checkout' do
    before do
      allow(self).to receive(:run_command).with command
    end

    context 'when source branch is set' do
      let(:command) { 'cd /home/deploy/rails_apps/coding_stype_guide && git checkout base_branch && git reset 12345678 --hard && git checkout -b source_branch' }

      it 'runs git checkout command' do
        expect(self).to receive(:run_command).with command
        git_checkout build.repository_path, commit_id: build.last_commit_id, base_branch: 'base_branch', source_branch: 'source_branch'
      end
    end

    context 'when source branch is not set' do
      let(:command) { 'cd /home/deploy/rails_apps/coding_stype_guide && git checkout base_branch && git reset 12345678 --hard' }

      it 'runs git checkout command' do
        expect(self).to receive(:run_command).with command
        git_checkout build.repository_path, commit_id: build.last_commit_id, base_branch: 'base_branch'
      end
    end
  end

  describe '#git_push' do
    before do
      allow(self).to receive(:run_command).with command
    end

    context 'when source branch is set' do
      let(:command) { "cd /home/deploy/rails_apps/coding_stype_guide && git add . && git commit -am 'Commit message' && git push origin source_branch && git checkout base_branch && git reset 12345678 --hard && git branch -D source_branch" }

      it 'runs git checkout command' do
        expect(self).to receive(:run_command).with command
        git_push build.repository_path, commit_id: build.last_commit_id, base_branch: 'base_branch', source_branch: 'source_branch', commit_message: 'Commit message'
      end
    end

    context 'when source branch is not set' do
      let(:command) { "cd /home/deploy/rails_apps/coding_stype_guide && git add . && git commit -am 'Commit message' && git push origin base_branch && git checkout base_branch && git reset 12345678 --hard" }

      it 'runs git checkout command' do
        expect(self).to receive(:run_command).with command
        git_push build.repository_path, commit_id: build.last_commit_id, base_branch: 'base_branch', commit_message: 'Commit message'
      end
    end
  end
end
