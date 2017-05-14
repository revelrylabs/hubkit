require 'spec_helper'

describe Hubkit::Issue do
  subject(:issue) do
    Hubkit::Issue.from_name('hubkit-test-machine-user/hubkit-test-repo/1')
  end

  describe '#from_name' do
    it 'construct the correct issue' do
      expect(issue.org).to eq 'hubkit-test-machine-user'
      expect(issue.repo).to eq 'hubkit-test-repo'

      VCR.use_cassette 'issue_from_name', record: :new_episodes do
       expect(issue.number).to eq 1
      end
    end
  end

  describe '#labels' do
    subject(:labels) do
      VCR.use_cassette 'issue_labels', record: :new_episodes do
        issue.labels
      end
    end

    it 'should return a label' do
      should eq ['bug']
    end
  end

  describe '#label!' do
    it 'can add labels' do
      labels = VCR.use_cassette 'issue_label!', record: :new_episodes do
        issue.label! 'duplicate'
      end

      expect(labels).to eq ['bug', 'duplicate']
    end
  end

  describe '#unlabel!' do
    it 'can unlabel the issue' do
      labels = VCR.use_cassette 'issue_label!', record: :new_episodes do
        issue.unlabel! { |label_name| label_name == 'duplicate' }
      end
      expect(labels).to include 'bug'
      expect(labels).to_not include 'duplicate'
    end
  end

  describe '#body' do
    it 'can return the body of the issue' do
      body = VCR.use_cassette 'issue_body', record: :new_episodes do
        issue.body
      end

      expect(body).to include 'hubkit'
    end
  end

  describe '#when_labeled' do
    it 'can get the date when an issue was labeled' do
      date = VCR.use_cassette 'issue_when_labeled', record: :new_episodes do
        issue.when_labeled('bug')
      end

      expect(date).to eq Time.parse('2017-04-10 00:18:44.000000000 +0000')
    end
  end

  describe '#when_opened' do
    it 'can get the date when an issue was opened' do
      date = VCR.use_cassette 'issue_when_opened', record: :new_episodes do
        issue.when_opened
      end

      expect(date).to eq Time.parse('2017-04-09 18:41:49.000000000 +0000')
    end
  end

  describe '#when_closed' do
    it 'can get the date when an issue was opened' do
      date = VCR.use_cassette 'issue_when_closed', record: :new_episodes do
        issue.when_closed
      end

      expect(date).to eq Time.parse('2017-04-10 01:42:55.000000000 +0000')
    end
  end

  describe '#users_ever_assigned' do
    it 'can get the list of users that were ever assigned to the issues' do
      users = VCR.use_cassette 'issue_users_ever_assigned', record: :new_episodes do
        issue.users_ever_assigned
      end

      expect(users).to eq ['hubkit-test-machine-user']
    end
  end

  describe '#to_text' do
    it 'can make a text summary of an issue' do
      text = VCR.use_cassette 'issue_users_ever_assigned', record: :new_episodes do
        issue.to_text
      end

      expect(text).to include 'hubkit'
    end
  end
end
