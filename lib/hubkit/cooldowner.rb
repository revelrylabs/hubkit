module Hubkit
  # An object that handles Github rate throttling by setting a delay and then
  # retrying a block
  class Cooldowner
    # Perform an action, and if Github rejects it due to rate limit, sleep and
    # try again later
    # @yield
    def self.with_cooldown
      cooldown = 1
      begin
        yield
      rescue Github::Error::Forbidden => e
        Logger.warn "Sleeping for abuse (#{cooldown} seconds)"
        sleep cooldown
        cooldown = [2 * cooldown, 10].min
        retry
      end
    end
  end
end
