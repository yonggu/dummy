require 'bitbucket/client'
require 'bitbucket/default'

module Bitbucket
  class << self
    include Bitbucket::Configurable
  end
end
