module Bitbucket
  module Configurable

    attr_accessor :client_id, :client_secret, :access_token, :access_token_secret

    class << self
      def keys
        @keys ||= [
          :client_id,
          :client_secret,
          :access_token,
          :access_token_secret
        ]
      end
    end

    def configure
      yield self
    end

  end
end
