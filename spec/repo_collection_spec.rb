require 'spec_helper'

describe Hubkit::RepoCollection do
  describe '#organization' do
    subject(:results) do
      VCR.use_cassette 'repo_collection_organization', record: :new_episodes do
        Hubkit::RepoCollection.new(Hubkit::RepoPaginator.new).organization('hubkit-test-machine-user')
      end
    end

    it { should respond_to :wrap }
    it { should respond_to :select }

    it 'should have results' do
      expect(results.length).to be >= 1
    end

    context 'with no matching repos' do
      subject(:results) do
        VCR.use_cassette 'repo_collection_organization_no_matches', record: :new_episodes do
          Hubkit::RepoCollection.new(Hubkit::RepoPaginator.new).organization('x-y-z')
        end
      end

      it { should respond_to :wrap }
      it { should respond_to :select }

      it 'should have results' do
        expect(results.length).to eq 0
      end
    end
  end

  describe '#fork' do
    subject(:results) do
      VCR.use_cassette 'repo_collection_fork', record: :new_episodes do
        Hubkit::RepoCollection.new(Hubkit::RepoPaginator.new).fork
      end
    end

    it { should respond_to :wrap }
    it { should respond_to :select }

    it 'should have results' do
      expect(results.length).to be >= 1
    end

    it 'should give only forks' do
      expect(results.first.fork).to eq true
    end
  end
end
