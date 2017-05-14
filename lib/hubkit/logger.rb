require 'logger'

module Hubkit
  class Logger
    def self.debug(msg)
      inner_logger.debug('[HUBKIT] ' + msg)
    end

    def self.info(msg)
      inner_logger.info('[HUBKIT] ' + msg)
    end

    def self.warn(msg)
      inner_logger.warn('[HUBKIT] ' + msg)
    end

    def self.error(msg)
      inner_logger.error('[HUBKIT] ' + msg)
    end

    def self.fatal(msg)
      inner_logger.fatal('[HUBKIT] ' + msg)
    end

    def self.unknown(msg)
      inner_logger.unknown('[HUBKIT] ' + msg)
    end

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
