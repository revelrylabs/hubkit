module Hubkit
  # Hold the configuration of the Hubkit library. Holds the client, default
  # github organization, and the github library configuration options.
  # @attr [Github::Client] client the underlying Github client used for library
  #   operations
  # @attr [String] default_org the github organization that will be used if
  #   none is specified
  # @attr [Hash] github_config the configuration to use for the github client
  #   as a Hash
  module Configuration
    class << self
      attr_writer :client
      attr_accessor :default_org
      attr_accessor :github_config

      # Set configuration for the library
      # @param [Hash] opts the configuration options to set
      # @yieldparam [Hubkit::Configuration] this configuration, which is passed
      #   to the block
      # @return [Github::Client] the github client to be used by the library
      def configure(opts = {}, &block)
        hubkit_config = self
        @client = Github.new do |github_config|
          hubkit_config.github_config = github_config
          yield hubkit_config
        end
      end

      # The underlying Github::Client that will be used for library operations
      # @return [Github::Client] a Github::Client which will be used for
      #   library operations
      def client
        @client || Github.new
      end

      # Pass through all method calls which are not implemented directly on the
      # Configuration to the client's configuration method
      # @param [String, Symbol] name the name of the method which is being called
      # @param [Array] args the array of arguments to the method
      # @yieldparam ... any arguments to the block required by the underlying
      #   Github::Client method
      # @return the same return value that the github configuration would return
      def method_missing(name, *args, &block)
        if github_config.present? && github_config.respond_to?(name, false)
          return github_config.public_send(name, *args, &block)
        end
        super
      end
    end
  end
end
