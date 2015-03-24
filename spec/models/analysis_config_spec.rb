require 'rails_helper'

RSpec.describe AnalysisConfig, :type => :model do
  let(:analysis_config) { create :analysis_config }

  describe '#support_autocorrect?' do
    context 'when its cop support autocorrect' do
      before do
        analysis_config.name = RuboCop::Cop::Cop.all.find{|cop| cop.method_defined?(:autocorrect)}.cop_name
      end

      it { expect(analysis_config.support_autocorrect?).to be_truthy }
    end

    context 'when its cop does not support autocorrect' do
      before do
        analysis_config.name = RuboCop::Cop::Cop.all.find{|cop| !cop.method_defined?(:autocorrect)}.cop_name
      end

      it { expect(analysis_config.support_autocorrect?).to be_falsey }
    end

    context 'when its cop does not exist' do
      before do
        analysis_config.name = 'NotExisted'
      end

      it { expect(analysis_config.support_autocorrect?).to be_falsey }
    end
  end
end
