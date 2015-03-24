require 'rails_helper'

RSpec.describe SlackConfig, :type => :model do
  let(:project) { create :github_project, name: 'xinminlabs/awesomecode.io' }
  let(:slack_config) { create :slack_config, project: project }
  let(:build) { create :build, project: project, last_commit_message: 'Initial import.', last_commit_id: '123456789', branch: 'dummy', author: 'yonggu' }

  describe '#send_notification' do
    before do
      @notifier = double(Slack::Notifier)
      allow(Slack::Notifier).to receive(:new).and_return(@notifier)
    end

    context 'when the build is successful' do
      before do
        build.update_attributes success: true
        allow(@notifier).to receive(:ping).with '', username: 'Awesome Code', attachments: attachments
      end

      it "sends correct message" do
        expect(@notifier).to receive(:ping).with '', username: 'Awesome Code', attachments: attachments

        slack_config.send_notification(build.id)
      end

      def message
        "<#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{build.id}|Build succeeded> for branch on <#{Figaro.env.domain_url}/projects/#{project.id}|xinminlabs/awesomecode.io> (<https://github.com/xinminlabs/awesomecode.io/commit/123456789|12345>)"
      end

      def attachments
        [{
          fallback: message,
          color: '#7CD197',
          fields: [
            {
              title: 'Build succeeded',
              value: "<#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{build.id}|Initial import.>",
              short: true
            },
            {
              title: 'Committer',
              value: 'yonggu',
              short: true
            },
            {
              title: 'Branch',
              value: 'dummy',
              short: true
            },
            {
              title: 'Project',
              value: 'xinminlabs/awesomecode.io',
              short: true
            }
          ]
        }]
      end
    end

    context 'when the build is not successful' do
      before do
        build.update_attributes success: false
        allow(@notifier).to receive(:ping).with '', username: 'Awesome Code', attachments: attachments
      end

      it 'sends correct message' do
        expect(@notifier).to receive(:ping).with '', username: 'Awesome Code', attachments: attachments

        slack_config.send_notification(build.id)
      end

      def message(project_id)
        "There seems to be a problem on branch dummy for <#{Figaro.env.domain_url}/projects/#{project_id}|xinminlabs/awesomecode.io>.\nMessage: Initial import. (<https://github.com/xinminlabs/awesomecode.io/commit/123456789|12345>)"
      end

      def attachments
        [{
          fallback: message(project.id),
          color: '#F35A00',
          fields: [
            {
              title: 'Build failed',
              value: "<#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{build.id}|Initial import.>",
              short: true
            },
            {
              title: 'Committer',
              value: 'yonggu',
              short: true
            },
            {
              title: 'Branch',
              value: 'dummy',
              short: true
            },
            {
              title: 'Project',
              value: 'xinminlabs/awesomecode.io',
              short: true
            }
          ]
        }]
      end
    end
  end
end
