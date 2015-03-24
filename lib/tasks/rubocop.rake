namespace :rubocop do
  desc 'Sync Rubocop'
  task :sync => :environment do
    if Gem.loaded_specs["rubocop"]
      version = Gem.loaded_specs["rubocop"].version.to_s
      unless File.exist? Rails.root.join('config', 'rubocop', version)
        set_version version
      end
    else
      Rails.logger.info 'RuboCop is not specified in Gemfile.'
    end
  end

  task :downgrade => :environment do
    current_version = Gem.loaded_specs["rubocop"].version
    versions = Rails.root.join('config', 'rubocop').children.select(&:directory?).map{|pathname| Gem::Version.new(pathname.basename.to_s)}
    previous_version = versions.select{|version| version < current_version}.max

    if previous_version
      set_version previous_version.to_s
    else
      Rails.logger.info 'No previous version is found.'
    end
  end

  task :set_version, [:version] => [:environment] do |task, args|
    version = args.version.presence
    set_version version
  end

  def set_version(version)
    unless version
      Rails.logger.info 'No version is specified.'
      return
    end

    directory = Rails.root.join('config', 'rubocop', version)
    FileUtils.mkdir_p directory

    begin
      %w(default.yml enabled.yml disabled.yml).each do |yml|
        Rails.logger.info "Going to download and save #{yml} to #{directory}."
        File.open(Rails.root.join(directory, yml), 'wb') do |file|
          file.write open("https://raw.githubusercontent.com/bbatsov/rubocop/v#{version}/config/#{yml}").read
        end
      end
    rescue Exception => e
      Rails.logger.error 'Failed to download. Please check the version and try it again.'
      FileUtils.rm_rf directory
      return
    end

    AnalysisConfig.set_version version
    Rails.logger.info "Set version to #{version} successfully."
  end
end
