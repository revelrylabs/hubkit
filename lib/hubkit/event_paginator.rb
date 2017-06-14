module Hubkit
  # Returns all events for a GitHub issues-- for example, labeling, unlabeling,
  # closing, etc-- and handle pagination for you
  class EventPaginator < Paginator
    include Enumerable

    # Initialize a new paginator for events from the API
    # @param [String] org the github organization which contains the repo for
    #   which we'll gather events
    # @param [String] repo the github repo name for which we'll gather events
    # @param [optional Fixnum] issue_number if present, the number of the issue
    #   for which we'll sfind events
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
