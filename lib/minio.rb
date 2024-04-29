# frozen_string_literal: true

require_relative "minio/version"
require_relative "minio/commands"
require_relative "minio/upstream"
require_relative "minio/railtie" if defined?(::Rails::Railtie)

module MinIO
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :username, :password

    def initialize
    end
  end
end
