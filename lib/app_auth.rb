require 'app_auth/version'
require 'app_auth/middleware'
require 'app_auth/user'

module AppAuth
  cattr_accessor :config

  class << self
    def configure
      self.config = OpenStruct.new
      yield(config) if block_given?
      config
    end
  end
end
