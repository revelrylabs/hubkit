require 'spec_helper'

describe Hubkit::Repo do
  describe '#list' do
    subject do
      VCR.use_cassette 'repo_list', record: :new_episodes do
        Hubkit::Repo.list
      end
    end

    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :select }
    it { is_expected.to respond_to :map }
    it { is_expected.to respond_to :fork }
  end

  describe '#from_gh' do
    subject do
      Hubkit::Repo.from_gh(
        Hashie::Mash.new(
          owner: {
            login: 'hubkit-test-machine-user',
          },
          name: 'hubkit-test-repo',
        )
      )
    end

    it { should respond_to :labels }
    it { should respond_to :issues }
  end

  describe '#inspect' do
    subject { Hubkit::Repo.from_name('hubkit-test-machine-user/hubkit-test-repo').inspect }

    it { should include 'hubkit-test-machine-user' }
    it { should include 'hubkit-test-repo' }
  end

  describe '#issues' do
    subject do
      VCR.use_cassette 'repo_issues_list', record: :new_episodes do
        Hubkit::Repo.from_name_with_default_org('hubkit-test-repo').issues
      end
    end

    it { should respond_to :each }
    it { should respond_to :select }
    it { should respond_to :open }
  end

  describe '#labels' do
    subject do
      VCR.use_cassette 'repo_labels_list', record: :new_episodes do
        Hubkit::Repo.from_name('hubkit-test-machine-user/hubkit-test-repo').labels
      end
    end

    it { should include 'bug' }
  end
end

