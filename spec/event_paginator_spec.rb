require 'spec_helper'

describe Hubkit::EventPaginator do
  subject(:paginator) {
    VCR.use_cassette 'event_collection', record: :new_episodes do
      Hubkit::EventPaginator.new(
        org: 'hubkit-test-machine-user',
        repo: 'hubkit-test-repo',
      ).to_a
    end
  }

  context 'for a repo-wide event list' do
    it { should_not be_empty }
  end
end
