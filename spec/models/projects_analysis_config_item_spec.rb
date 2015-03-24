require 'rails_helper'

RSpec.describe ProjectsAnalysisConfigItem, :type => :model do
  let(:analysis_config_item) { create :analysis_config_item, value: ['one', 'two'] }
  let(:projects_analysis_config_item) { create :projects_analysis_config_item, value: 'three,four', analysis_config_item: analysis_config_item }

  describe '#normalize_value' do
    it { expect(projects_analysis_config_item.value).to eq(['three', 'four']) }

    context 'when the value of its analysis config item is not a Array' do
      before do
        analysis_config_item.value = 'one'
        analysis_config_item.save
      end

      it { expect(projects_analysis_config_item.value).to eq('three,four') }
    end

    context 'when the value is a Array' do
      before do
        projects_analysis_config_item.value = ['three', 'four']
        projects_analysis_config_item.save
      end

      it { expect(projects_analysis_config_item.value).to eq(['three', 'four']) }
    end
  end
end
