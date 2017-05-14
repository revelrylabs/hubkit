# Represents one issue in github
module Hubkit
  class Issue
    # i.e. dingus/123 or foobar/dingus/123
    ISSUE_PATTERN = %r{
      (
        (?<org>[^/]+)/(?<repo>[^/]+)
        |
        (?<repo>[^/]+)
      )
      /
      (?<number>[0-9]+)
    }x

    def self.from_name(name)
      new(**parameters_from_name(name))
    end

    def self.parameters_from_name(name)
      match_data = Issue::ISSUE_PATTERN.match(name)
      {
        org: match_data[:org] || Hubkit::Configuration.default_org,
        repo: match_data[:repo],
        number: match_data[:number],
      }
    end

    def self.from_gh(org:, repo:, gh:)
      new(org: org, repo: repo, number: gh['number']).tap do |issue|
        issue.instance_variable_set(:@_to_gh, gh)
      end
    end

    attr_accessor :org, :repo, :number

    def initialize(org:, repo:, number:)
      @org = org
      @repo = repo
      @number = number
    end

    def to_gh
      @_to_gh ||= Github.issues.get(@org, @repo, @number).body
    end

    def labels
      @_labels ||= to_gh['labels'].map { |label| label.name.downcase }
    end

    def label!(string)
      Hubkit.client.issues.labels.add @org, @repo, @number, string
      labels.append(string).uniq!
    end

    def unlabel!(&block)
      fail('Block is required for unlabel') unless block_given?
      to_gh.labels.map(&:name)
      .select do |label_name|
        yield label_name
      end
      .each do |label_name|
        Hubkit.client.issues.labels.remove @org, @repo, @number, label_name: label_name
        labels.delete(label_name)
      end
      labels
    end

    delegate :title, :number, to: :to_gh

    def body
      to_gh.body
    end

    def pull?
      to_gh['pull_request'].present?
    end

    def true_issue?
      !pull?
    end

    def when_labeled(x)
      return unless events.labeled(x).any?
      Time.parse(events.labeled(x).first['created_at'])
    end

    def when_opened
      Time.parse(created_at)
    end

    def when_closed
      return unless events.closed.any?
      Time.parse(events.closed.first['created_at'])
    end

    def events
      @_events ||=
        EventCollection.new(
          event_paginator,
        )
        .reverse_chronological
    end

    def event_paginator
      EventPaginator.new(
        org: @org,
        repo: @repo,
        issue_number: @number,
      )
    end

    def users_ever_assigned
      events
        .select { |event| event.event == 'assigned' }
        .map { |event| event.assignee.login }
        .uniq
    end

    def to_text
      "#{number}: #{title}\n---\n#{body}\n"
    end

    def method_missing(name, *args, &block)
      return to_gh[name] if args.length == 0 && !block_given? && to_gh.key?(name)
      super
    end
  end
end
