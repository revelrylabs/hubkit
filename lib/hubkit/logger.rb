require 'logger'

module Hubkit
  # The logger Hubkit uses for diagnostic info. If used in a Rails app and
  # that Rails app already has a logger, it will use that same logger.
  # Prepends [HUBKIT] to all log statements for easy filtering.
  class Logger
    # Write a debug level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.debug(msg)
      inner_logger.debug('[HUBKIT] ' + msg)
    end

    # Write a info level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.info(msg)
      inner_logger.info('[HUBKIT] ' + msg)
    end

    # Write a warning level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.warn(msg)
      inner_logger.warn('[HUBKIT] ' + msg)
    end

    # Write a error level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.error(msg)
      inner_logger.error('[HUBKIT] ' + msg)
    end

    # Write a fatal level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.fatal(msg)
      inner_logger.fatal('[HUBKIT] ' + msg)
    end

    # Write a unknown level message to the log
    # @param [String] msg the message to log
    # @return [Boolean] true
    def self.unknown(msg)
      inner_logger.unknown('[HUBKIT] ' + msg)
    end

    # Return the ruby logger used by Hubkit
    # @return [Logger] the logger. Rails is in use, will reuse the Rails
    #   logger.
    def self.inner_logger
      @_inner_logger ||=
        if Kernel.const_defined? 'Rails'
          Rails.logger
        else
          ::Logger.new(STDERR)
        end
    end
  end
end
