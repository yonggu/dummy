require 'rails_helper'

RSpec.describe ProjectsAnalysisConfig, :type => :model do
  let(:project) { create :project, included_files: ['**/*.gemspec', '**/*.podspec'], excluded_files: ['vendor/**/*'] }
  let(:analysis_config) { create :analysis_config, name: 'Style/AlignParameters' }
  let(:projects_analysis_config) { create :projects_analysis_config, enabled: true, project: project, analysis_config: analysis_config }
  let(:analysis_config_item) { create :analysis_config_item, name: 'Include', value: ['app/models/*.rb'] }
  let!(:projects_analysis_config_item) { create :projects_analysis_config_item, projects_analysis_config: projects_analysis_config,
                                                                                analysis_config_item: analysis_config_item,
                                                                                value: ['app/models/*.rb', 'app/controllers/*.rb'] }

  describe "#full_config" do
    context "when it's analysis config supports rails" do
      let(:analysis_config) { create :analysis_config, name: 'Rails/Validation' }

      it { expect(projects_analysis_config.full_config).to eq({"inherit_from"=>["enabled.yml", "disabled.yml"], "AllCops"=>{"Include"=>["**/*.gemspec", "**/*.podspec"], "Exclude"=>["vendor/**/*"], "RunRailsCops"=>true}, "Rails/Validation"=>{"Include"=>["app/models/*.rb", "app/controllers/*.rb"]}}) }
    end

    context "when it's analsis config does not support rails" do
      let(:analysis_config) { create :analysis_config, name: 'Style/AlignParameters' }

      it { expect(projects_analysis_config.full_config).to eq({"inherit_from"=>["enabled.yml", "disabled.yml"], "AllCops"=>{"Include"=>["**/*.gemspec", "**/*.podspec"], "Exclude"=>["vendor/**/*"], "RunRailsCops"=>false}, "Style/AlignParameters"=>{"Include"=>["app/models/*.rb", "app/controllers/*.rb"]}}) }
    end
  end

  describe '#config' do
    it { expect(projects_analysis_config.config).to eq({"Style/AlignParameters"=>{"Include"=>["app/models/*.rb", "app/controllers/*.rb"]}}) }
  end

  describe "#configs" do
    it { expect(projects_analysis_config.configs).to eq({ 'Include' => ['app/models/*.rb', 'app/controllers/*.rb'] }) }
  end
end
