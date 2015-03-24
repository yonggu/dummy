require 'spec_helper'
require 'analyzers/rubocop_analyzer'

describe RubocopAnalyzer do
  let(:config) {
    {
      'inherit_from' => ['enabled.yml', 'disabled.yml'],
      'AllCops' => {
        'Include' => ['**/*.rake'],
        'Exclude' => ['vendor/**/*']
      },
      'Style/AlignParameters' => { 'EnforcedStyle' => 'with_first_parameter' }
    }
  }
  let(:path) { Rails.root.join('spec', 'fixtures', 'rubocop_demo').to_s }
  let(:cop_class) { RuboCop::Cop::Style::AlignParameters }
  let(:analyzer) { RubocopAnalyzer.new(path, cop_class, config) }

  before do
    # Prevent auto correct file in test environment.
    allow(File).to receive(:open).with(Rails.root.join(path, 'file_with_offense.rb').to_s, 'w')
  end

  describe '#run' do
    subject { analyzer.run }

    it { expect(subject[:files]).to be_present }
  end

  describe '#find_target_files' do
    subject { analyzer.send :find_target_files, path, config }

    %w(file_with_offense.rb file_without_offense.rb demo.rake).each do |file|
      it "includes rubocop_demo/#{file}" do
        expect(subject).to be_include File.join(path, file)
      end
    end

    %w(dummy.txt vendor/demo.rb).each do |file|
      it "excludes rubocop_demo/#{file}" do
        expect(subject).not_to be_include File.join(path, file)
      end
    end
  end
end
