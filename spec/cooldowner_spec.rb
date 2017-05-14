require 'spec_helper'

describe Hubkit::Cooldowner do
  it 'can recover from a rate limit' do
    allow(Hubkit::Logger).to receive(:warn)

    i = 0
    Hubkit::Cooldowner.with_cooldown do
      next if i > 0
      i += 1
      raise Github::Error::Forbidden.new(
        response_headers: {},
        body: 'Rate limit',
        status: 403,
      )
    end
    expect(i).to be >= 1
  end
end
