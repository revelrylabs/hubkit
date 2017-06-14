module Hubkit
  # A collection of GitHub issues with chainable filters
  class IssueCollection < ChainableCollection
    # Filters to issues which where at some point labeled with the given label
    # regardless of whether it currently has that label or not
    # @param [String] label the label in question
    # @return [IssueCollection] a collection of issues which were ever labeled
    #   with that label
    def ever_labeled(label)
      wrap(
        @inner.select do |issue|
          issue.when_labeled(label).present?
        end,
      )
    end

    # Return a collection of issues which are open
    # @return [IssueCollection] the issues in the collection which are open
    def open
      wrap(@inner.select { |issue| issue.state == "open" })
    end

    # Return a collection of issues which are closed
    # @return [IssueCollection] the issues in the collection which are closed
    def closed
      wrap(@inner.select { |issue| issue.state == "closed" })
    end

    # Return a collection of issues which are labeled with any of the given
    # labels
    # @param [Enumerable, String] labels if a string, then this is the single
    #   label used to filter issues. If it is an enumerable set of strings,
    #   any issues matching any of the labels will be returned.
    # @return [IssueCollection] a collection of matching the label
    def labeled(labels)
      return wrap(labels.flat_map { |label| labeled(label) }) if labels.respond_to?(:map)

      wrap(@inner.select do |issue|
        issue.labels.include?(labels.downcase)
      end)
    end

    # Return a collection of issues which are not labeled
    # @return [IssueCollection] a collection of issues without labels
    def unlabeled
      wrap(@inner.select { |issue| issue.labels.empty? })
    end

    # Return a collection of issues which have labels matching a pattern
    # @param [Regex] label_pattern a pattern which issues must match to be
    #   included in the collection
    # @return [IssueCollection] a collection of issues with labels matching
    #   the pattern
    def labeled_like(label_pattern)
      wrap(@inner.select do |issue|
        issue.labels.any? { |label| label_pattern.match(label) }
      end)
    end

    # Return issues which are not pull requests
    # @return [IssueCollection] a collection of issues which are not pull
    #   requests
    def true_issues
      wrap(@inner.select(&:true_issue?))
    end

    # Return issues which are pull requests
    # @return [IssueCollection] a collection of issues which are pull requests
    def pulls
      wrap(@inner.select(&:pull?))
    end

    # Return issues which are unassigned
    # @return [IssueCollection] a collection of issues which are unassigned
    def unassigned
      wrap(@inner.select { |issue| issue.assignee.nil? })
    end

    # Returns issues opened within a date window between start_dt and end_dt
    # @param [Date] start_dt the beginning date of the filter window (inclusive)
    # @param [Date] end_dt the end date of the filter window (exclusive)
    # @return [IssueCollection] a collection of issues opened within the window
    def opened_between(start_dt, end_dt)
      wrap(
        @inner.select do |issue|
          start_dt <= issue.when_opened && issue.when_opened < end_dt
        end,
      )
    end

    # Group the issue collection by the current assignee
    # @return [Hash] a hash, where the assignee's username is the key, and the
    #   values are IssueCollections of issues assigned to that user
    def by_assignee
      groups = group_by { |issue| issue.assignee.try(:login) }
      groups.each_with_object(groups) do |(key, list), memo|
        memo[key] = wrap(list)
      end
    end
  end
end
