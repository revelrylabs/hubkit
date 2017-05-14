# Returns the list of issues for a repo, handling pagination for you
module Hubkit
  class IssuePaginator < Paginator
    include Enumerable

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
