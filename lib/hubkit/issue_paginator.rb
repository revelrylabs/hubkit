module Hubkit
  # Returns the list of issues for a repo, handling pagination for you
  class IssuePaginator < Paginator
    include Enumerable

    # Initialize a new paginator for issues from the API
    # @param [String] org the github organization which contains the repo for
    #   which we'll gather issues
    # @param [String] repo the github repo name for which we'll gather issues
    # @param [optional String] state if missing or open, the paginator will
    #   only have open issues returned. If 'all', the paginator will give you
    #   open and closed issues.
    def initialize(org:, repo:, state: 'open')
      @org = org
      @repo = repo
      super() do |i|
        Cooldowner.with_cooldown do
          Github.issues.list(user: @org, repo: @repo, state: state, page: i)
        end
      end
    end
  end
end
