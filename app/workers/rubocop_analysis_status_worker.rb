class RubocopAnalysisStatusWorker
  include Resque::Plugins::Status

  @queue = :rubocop_analysis

  def perform
    build = Build.find options['build_id']
    build.run!
  end
end
