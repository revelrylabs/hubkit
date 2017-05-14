module Hubkit
  module Configuration
    class << self
      attr_writer :client
      attr_accessor :default_org
      attr_accessor :github_config

      def configure(opts = {}, &block)
        hubkit_config = self
        @client = Github.new do |github_config|
          hubkit_config.github_config = github_config
          yield hubkit_config
        end
      end

      def client
        @client || Github.new
      end

      def method_missing(name, *args, &block)
        if github_config.present? && github_config.respond_to?(name, false)
          return github_config.public_send(name, *args, &block)
        end
        super
      end
    end
  end
end
