# A collection of GitHub issues with chainable filters
module Hubkit
  class IssueCollection < ChainableCollection
    # Was at some point labeled x whether it is currently
    def ever_labeled(x)
      wrap(
        @inner.select do |issue|
          issue.when_labeled(x).present?
        end,
      )
    end

    def open
      wrap(@inner.select { |issue| issue.state == "open" })
    end

    def closed
      wrap(@inner.select { |issue| issue.state == "closed" })
    end

    def labeled(x)
      return wrap(x.flat_map { |label| labeled(label) }) if x.respond_to?(:map)

      wrap(@inner.select do |issue|
        issue.labels.include?(x.downcase)
      end)
    end

    def unlabeled
      wrap(@inner.select { |issue| issue.labels.empty? })
    end

    def labeled_like(x)
      wrap(@inner.select do |issue|
        issue.labels.any? { |label| x.match(label) }
      end)
    end

    def true_issues
      wrap(@inner.select(&:true_issue?))
    end

    def pulls
      wrap(@inner.select(&:pull?))
    end

    def unassigned
      wrap(@inner.select { |issue| issue.assignee.nil? })
    end

    def opened_between(start_dt, end_dt)
      wrap(
        @inner.select do |issue|
          start_dt <= issue.when_opened && issue.when_opened < end_dt
        end,
      )
    end

    def by_assignee
      groups = group_by { |issue| issue.assignee.try(:login) }
      groups.each_with_object(groups) do |(key, list), memo|
        memo[key] = wrap(list)
      end
    end
  end
end
