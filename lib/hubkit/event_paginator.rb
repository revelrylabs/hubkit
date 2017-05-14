# Returns all events for a GitHub issues-- for example, labeling, unlabeling,
# closing, etc-- and handle pagination for you
module Hubkit
  class EventPaginator < Paginator
    include Enumerable

    def initialize(org:, repo:, issue_number: nil)
      @org = org
      @repo = repo
      @issue_number = issue_number

      opts =
        if issue_number.present?
          { issue_number: issue_number }
        else
          {}
        end

      super() do |i|
        Cooldowner.with_cooldown do
          Hubkit.client.issues.events.list(
            @org,
            @repo,
            opts.merge(page: i),
          )
        end
      end
    end
  end
end
