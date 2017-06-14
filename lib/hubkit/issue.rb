module Hubkit
  # Represents one issue in github
  # @attr [String] org the github organization name of the issue
  # @attr [String] repo the github repo name
  # @attr [Fixnum] number the issue's number
  class Issue
    # A regex which matches a textual name of an issue i.e. dingus/123 or
    # foobar/dingus/123
    ISSUE_PATTERN = %r{
      (
        (?<org>[^/]+)/(?<repo>[^/]+)
        |
        (?<repo>[^/]+)
      )
      /
      (?<number>[0-9]+)
    }x

    # Create an Issue model from the textual name of the issue
    # @example
    #   Hubkit::Issue.from_name('foobar/dingus/123')
    # @param [String] name a string name for an issue, like dingus/123 or
    #   foobar/dingus/123
    # @return [Hubkit::Issue] the issue matching this org, repo, and number
    def self.from_name(name)
      new(**parameters_from_name(name))
    end

    # Parse an issue name into org, repo, and number
    # @param [String] name a string like dingus/123 or foobar/dingus/123
    # @return [Hash] a hash containing org:, repo:, and number: values
    def self.parameters_from_name(name)
      match_data = Issue::ISSUE_PATTERN.match(name)
      {
        org: match_data[:org] || Hubkit::Configuration.default_org,
        repo: match_data[:repo],
        number: match_data[:number],
      }
    end

    # Create an Issue model from a github api payload. Preseeds the github
    # payload of the model to avoid refetching from the API later.
    # @param [String] org the github organization of the issue
    # @param [String] repo the repo name of the issue
    # @param [Hash] gh the payload hash from the API
    def self.from_gh(org:, repo:, gh:)
      new(org: org, repo: repo, number: gh['number']).tap do |issue|
        issue.instance_variable_set(:@_to_gh, gh)
      end
    end

    attr_accessor :org, :repo, :number

    # Create a new issue model
    # @param [String] org the github organization name of the issue
    # @param [String] repo the github repo name
    # @param [Fixnum] number the issue's number
    def initialize(org:, repo:, number:)
      @org = org
      @repo = repo
      @number = number
    end

    # The issue payload from the github API
    # @return [Github::Mash] a hash-like object of the github API response
    def to_gh
      @_to_gh ||= Github.issues.get(@org, @repo, @number).body
    end

    # A list of all of the current labels of the issue
    # @return [Enumerable] the list of labels
    def labels
      @_labels ||= to_gh['labels'].map { |label| label.name.downcase }
    end

    # Add a label to an issue
    # @param [String] label the label to add to the issue
    # @return [Enumerable] the new list of labels including the addition
    def label!(label)
      Hubkit.client.issues.labels.add @org, @repo, @number, label
      labels.append(label).uniq!
    end

    # Remove a label from an issue
    # @yieldparam [String] label_name a current label. if the block returns
    #   true, this label will be removed from the list
    # @return [Enumerable] the new list of labels after any removals
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

    delegate :title, :number, :body, to: :to_gh

    # Returns true if the issue is a pull request
    # @return [Boolean] true if the issue is a pull request, otherwise false
    def pull?
      to_gh['pull_request'].present?
    end

    # Returns true if the issue is not a pull request
    # @return [Boolean] false if the issue is a pull request, otherwise true
    def true_issue?
      !pull?
    end

    # Returns the time at which the issue was labeled `label`. It will return
    # the time of the latest such event.
    # @param [String] label the label to search for
    # @return [Date] the date when that issue was labeled such.
    def when_labeled(label)
      return unless events.labeled(label).any?
      Time.parse(events.labeled(label).first['created_at'])
    end

    # Returns when the issue was opened
    # @return [DateTime] the DateTime when the issue was created
    def when_opened
      Time.parse(created_at)
    end

    # Returns when the issue was closed
    # @return [DateTime] the DateTime when the issue was closed
    def when_closed
      return unless events.closed.any?
      Time.parse(events.closed.first['created_at'])
    end

    # The EventCollection of events related to this Issue
    # @return [EventCollection] the events for this issue, in reverse chronological order
    def events
      @_events ||=
        EventCollection.new(
          event_paginator,
        )
        .reverse_chronological
    end

    # Returns a paginator for fetching all events for this issue
    # @return [EventPaginator] the paginator for fetching all events for this issue
    def event_paginator
      EventPaginator.new(
        org: @org,
        repo: @repo,
        issue_number: @number,
      )
    end

    # Return the list of usernames of every user ever assigned to an issue
    # @return [Enumerable] the usernames of the users which have been assigned
    #   to the issue
    def users_ever_assigned
      events
        .select { |event| event.event == 'assigned' }
        .map { |event| event.assignee.login }
        .uniq
    end

    # A plaintext version of the issue, with the name, title, and body
    # @return [String] a string containing the name, title, and body, suitable
    #   for uses like export or chat integration
    def to_text
      "#{number}: #{title}\n---\n#{body}\n"
    end

    # Allow access to elements of the github payload by calling the names as
    # methods
    # @param [String, Symbol] name
    # @param [Array] args should be empty, only needed to match the expected
    #   signature from Ruby
    # @return the value of to_gh[name]
    def method_missing(name, *args, &block)
      return to_gh[name] if args.length == 0 && !block_given? && to_gh.key?(name)
      super
    end
  end
end
