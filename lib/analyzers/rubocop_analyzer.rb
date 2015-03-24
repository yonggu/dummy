class RubocopAnalyzer
  include RuboCop::PathUtil

  def initialize(path, cop_class, config)
    @path = path
    @cop_class = cop_class
    @config = config
  end

  def run
    result = { files: [] }

    cop = @cop_class.new RuboCop::Config.new @config, @path
    find_target_files(@path, @config).each do |path|
      new_source = autocorrect_source cop, File.read(path)
      if cop.support_autocorrect? && cop.offenses.present?
        File.open(path, 'w') { |file| file.write new_source }
        result[:files] << hash_for_file(path, cop.offenses, @path)
      end
      cop.reset
    end

    result
  end

  private

  # Refer to https://github.com/bbatsov/rubocop/blob/v0.28.0/lib/rubocop/runner.rb#find_target_files
  # It adds config to be the second parameter, which is used to set options_config for RuboCop::ConfigStore
  def find_target_files(path, config)
    make_exclude_absolute path, config

    config_store = RuboCop::ConfigStore.new
    config_store.options_config = config

    target_finder = RuboCop::TargetFinder.new(config_store, { debug: false })
    target_files = target_finder.find([path])
    target_files.each(&:freeze).freeze
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/lib/rubocop/formatter/json_formatter.rb#hash_for_file
  def hash_for_file(file, offenses, base_dir = Dir.pwd)
    {
      path:     relative_path(file, base_dir),
      offenses: offenses.map { |offense| hash_for_offense(offense) }
    }
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/lib/rubocop/formatter/json_formatter.rb#hash_for_offense
  def hash_for_offense(offense)
    {
      severity: offense.severity.name,
      message:  offense.message,
      cop_name: offense.cop_name,
      corrected: offense.corrected?,
      location: hash_for_location(offense)
    }
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/lib/rubocop/formatter/json_formatter.rb#hash_for_location
  def hash_for_location(offense)
    {
      line:   offense.line,
      column: offense.real_column,
      length: offense.location.length
    }
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/spec/support/cop_helper.rb#parse_source
  def parse_source(source, file = nil)
    source = source.join($RS) if source.is_a?(Array)

    if file && file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    RuboCop::ProcessedSource.new(source, file)
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/spec/support/cop_helper.rb#autocorrect_source
  def autocorrect_source(cop, source, file = nil)
    cop.instance_variable_get(:@options)[:auto_correct] = true
    processed_source = parse_source(source, file)
    _investigate(cop, processed_source)

    corrector = RuboCop::Cop::Corrector.new(processed_source.buffer, cop.corrections)
    corrector.rewrite
  end

  # From https://github.com/bbatsov/rubocop/blob/v0.28.0/spec/support/cop_helper.rb#_investigate
  def _investigate(cop, processed_source)
    forces = RuboCop::Cop::Force.all.each_with_object([]) do |klass, instances|
               next unless cop.join_force?(klass)
               instances << klass.new([cop])
             end

    commissioner = RuboCop::Cop::Commissioner.new([cop], forces, raise_error: false)
    commissioner.investigate(processed_source)
    commissioner
  end

  # Refer to https://github.com/bbatsov/rubocop/blob/v0.28.0/lib/rubocop/config.rb#make_excludes_absolute
  # It passes in the path and config to make the exclude configs with absolute path.
  def make_exclude_absolute path, config
    return unless config['AllCops'] && config['AllCops']['Exclude']

    config['AllCops']['Exclude'].map! do |exclude_elem|
      if exclude_elem.is_a?(String) && !exclude_elem.start_with?('/')
        File.join(path, exclude_elem)
      else
        exclude_elem
      end
    end
  end
end

module RuboCop
  module Cop
    class Cop
      def reset
        @offenses = []
        @corrections = []
      end
    end
  end

  class ConfigStore
    def options_config=(options_config)
      if options_config.is_a?(Hash)
        @options_config = Config.new options_config, RuboCop::ConfigLoader::DEFAULT_FILE
      else
        loaded_config = ConfigLoader.load_file(options_config)
        @options_config = ConfigLoader.merge_with_default(loaded_config, options_config)
      end
    end
  end
end
