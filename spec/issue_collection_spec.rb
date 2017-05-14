require 'spec_helper'

describe Hubkit::IssueCollection do
  let!(:paginator) {
    VCR.use_cassette 'issue_collection_paginator', record: :new_episodes do
      Hubkit::IssuePaginator.new(
        org: 'hubkit-test-machine-user',
        repo: 'hubkit-test-repo',
        state: 'all',
      ).map do |gh|
        Hubkit::Issue.from_gh(
          org: 'hubkit-test-machine-user',
          repo: 'hubkit-test-repo',
          gh: gh,
        )
      end
    end
  }

  subject(:issues_and_pulls) do
    Hubkit::IssueCollection.new(paginator)
  end

  subject(:issues) do
    issues_and_pulls.true_issues
  end

  describe '#ever_labeled' do
    subject(:labeled) do
      VCR.use_cassette 'issue_collection_events', record: :new_episodes do
        issues.ever_labeled 'bug'
      end
    end

    it { should have(1).items }
    it { expect(labeled.first.number).to eq 1 }
  end

  describe '#open' do
    subject(:open) { issues.open }

    it { should have(2).items }
    it { expect(open.map(&:number).sort).to eq [1, 3] }
  end

  describe '#closed' do
    subject(:closed) { issues.closed }

    it { should have(1).items }
    it { expect(closed.first.number).to eq 2 }
  end

  describe '#labeled' do
    subject(:labeled) { issues.labeled 'bug' }

    it { should have(1).items }
    it { expect(labeled.first.number).to eq 1 }
  end

  describe '#unlabeled' do
    subject(:unlabeled) { issues.unlabeled }

    it { should have(2).items }
    it { expect(unlabeled.map(&:number).sort).to eq [2, 3] }
  end

  describe '#labeled_like' do
    subject(:labeled) { issues.labeled_like /b.g/ }

    it { should have(1).items }
    it { expect(labeled.first.number).to eq 1 }
  end

  describe '#pulls' do
    subject(:pulls) { issues_and_pulls.pulls }

    it { should have(1).items }
    it { expect(pulls.first.number).to eq 4 }
  end

  describe '#unassigned' do
    subject(:unassigned) { issues.unassigned }

    it { should have(1).items }
    it { expect(unassigned.map(&:number).sort).to eq [2] }
  end

  describe '#opened_between' do
    subject(:opened_between) { issues.opened_between('2017-04-08', '2017-04-10') }

    it { should have(1).items }
    it { expect(opened_between.first.number).to eq 1 }
  end

  describe '#by_assignee' do
    subject(:by_assignee) { issues.by_assignee['prehnRA'] }

    it { should have(1).items }
    it { expect(by_assignee.map(&:number).sort).to eq [3] }
  end
end
