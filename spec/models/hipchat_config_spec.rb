require 'rails_helper'

RSpec.describe HipchatConfig, :type => :model do
  describe "#send_notification" do
    let(:project) { create :bitbucket_project, name: 'xinminlabs/awesomecode.io' }
    let(:hipchat_config) { create :hipchat_config, project: project }
    let(:build) { create :build, project: project, last_commit_id: '123456789', branch: 'dummy', author: 'yonggu' }

    it "gets success notification right msg" do
      hipchat_room = double(send: '')
      allow(HipChat::Client).to receive(:new).and_return({"Room" => hipchat_room})
      build.update_attributes success: true
      expect(hipchat_room).to receive(:send).with("Awesome Code",
                                                  "<a href='#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{build.id}'> Build succeeded </a> for branch dummy on <a href='#{Figaro.env.domain_url}/projects/#{project.id}'>xinminlabs/awesomecode.io</a> (<a href='https://bitbucket.org/xinminlabs/awesomecode.io/commits/123456789'>12345</a>)",
                                                  {:color=>"green", :notify=>true})
      hipchat_config.send_notification(build.id)
    end

    it "gets fail notification right msg" do
      hipchat_room = double(send: '')
      allow(HipChat::Client).to receive(:new).and_return({"Room" => hipchat_room})
      build.update_attributes success: false
      expect(hipchat_room).to receive(:send).with("Awesome Code",
                                                  "There seems to be a problem on branch dummy for <a href='#{Figaro.env.domain_url}/projects/#{project.id}'>xinminlabs/awesomecode.io</a>. yonggu <a href='#{Figaro.env.domain_url}/projects/#{project.id}/builds/#{build.id}'>should know about it</a><br>Message:  (<a href='https://bitbucket.org/xinminlabs/awesomecode.io/commits/123456789'>12345</a>)",
                                                  {:color=>"red", :notify=>true})
      hipchat_config.send_notification(build.id)
    end
  end
end
