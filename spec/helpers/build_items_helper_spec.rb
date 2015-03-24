require 'rails_helper'

RSpec.describe BuildItemsHelper, :type => :helper do

  describe "build_item_state_tag" do
    subject { helper.build_item_state_tag(build_item) }

    context 'when build item is passed' do
      let(:build_item) { create :build_item, passed: true }

      it { expect(subject).to eq '<span class="label label-success">Success</span>' }
    end

    context 'when build is already push directly' do
      let(:build_item) do
        create(:build_item, passed: false).tap do |build_item|
          expect(build_item).to receive(:already_push_directly?).and_return(true)
        end
      end

      it { expect(subject).to eq '<span class="label label-info">Already pushed directly</span>' }
    end

    context 'when build is already pull request' do
      let(:build_item) do
        create(:build_item, passed: false).tap do |build_item|
          expect(build_item).to receive(:already_push_directly?).and_return(false)
          expect(build_item).to receive(:already_pull_request?).and_return(true)
        end
      end

      it { expect(subject).to eq '<span class="label label-info">Already sent a pull request</span>' }
    end

    context 'when build is failed' do
      let(:build_item) do
        create(:build_item, passed: false).tap do |build_item|
          expect(build_item).to receive(:already_push_directly?).and_return(false)
          expect(build_item).to receive(:already_pull_request?).and_return(false)
        end
      end

      it { expect(subject).to eq '<span class="label label-danger">Failure</span>' }
    end
  end

end
