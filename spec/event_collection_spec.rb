require 'spec_helper'

describe Hubkit::EventCollection do
  let!(:paginator) {
    VCR.use_cassette 'event_collection', record: :new_episodes do
      Hubkit::EventPaginator.new(
        org: 'hubkit-test-machine-user',
        repo: 'hubkit-test-repo',
        issue_number: 1,
      ).to_a
    end
  }

  subject(:collection) do
    Hubkit::EventCollection.new paginator
  end

  describe '#reverse_chronological' do
    subject do
      collection.reverse_chronological
    end

    it 'should order the events from oldest to newest' do
      expect(subject[0].created_at).to be >= subject[1].created_at
    end
  end

  describe '#chronological' do
    subject do
      collection.chronological
    end

    it 'should order the events from newest to oldest' do
      expect(subject[0].created_at).to be <= subject[1].created_at
    end
  end

  describe '#between' do
    subject do
      collection.between(
        Time.parse('2017-04-10 00:18:44.000000000 +0000'),
        Time.parse('2017-04-10 01:42:55.000000000 +0000'),
      )
    end

    it 'should return events between the dates' do
      expect(subject.first.created_at).to be > collection.first.created_at
      expect(subject.last.created_at).to be < collection.last.created_at
    end
  end
end
