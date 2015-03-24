module Bitbucket
  module Default
    ENDPOINT = "https://api.bitbucket.org".freeze

    class << self
      def options
        Hash[Bitbucket::Configurable.keys.map{|key| [key, send(key)]}]
      end
    end
  end
end
