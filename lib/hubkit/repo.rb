module Hubkit
  # Represents one GitHub repo
  # @attr [String] org the github organization containing the repo
  # @attr [String] repo the github repo name
  class Repo
    attr_accessor :org, :repo

    # List available repos
    # @param [optional String] visibility if missing or 'all', retrieves all
    #   repos. if 'public', only retrieves public repos
    # @return [Enumerable] a list of Repo models accessible with the current
    #   credentials
    def self.list(visibility='all')
      RepoCollection.new(
        RepoPaginator
          .new(visibility)
          .map { |repo| { org: repo.owner.login, repo: repo.name } }
          .map { |params| new(**params) }
      )
    end

    # Initialize a Repo model from a github API payload
    # @param [Github::Mash] gh the github API response
    # @return [Repo] the matching Repo model
    def self.from_gh(gh)
      new(org: gh['owner']['login'], repo: gh.name)
    end

    # Initialize a Repo model from the name of the repo within the default
    # organization
    # @param [String] name the name of the repo
    # @return [Repo] the matching Repo model
    def self.from_name_with_default_org(name)
      fail('Hubkit::Configuration.default_org is not set') if Hubkit::Configuration.default_org.nil?
      return from_name(name) if name.include?('/')
      from_name "#{Hubkit::Configuration.default_org}/#{name}"
    end

    # Initialize a Repo model from the organization and repo name
    # @param [String] name the name of the organization/repo separated by a slash (/)
    # @return [Repo] the matching Repo model
    def self.from_name(name)
      org, repo = name.split('/')
      self.new(org: org, repo: repo)
    end

    # Construct a Repo model from the organization and repo name
    # @param [String] org the name of the github organization
    # @param [String] repo the name of the github repo
    def initialize(org:, repo:)
      @org = org
      @repo = repo
    end

    # A list of issues for this Repo
    # @param [Boolean] include_closed if true, will include closed issue. if
    #   false or missing, the result will only include open issues
    # @return [IssueCollection] the list of issues for the repo
    def issues(include_closed = false)
      issues_and_pulls(include_closed).true_issues
    end

    delegate :pulls, to: :issues_and_pulls

    # A list of issues and pull requests for this Repo
    # @param [Boolean] include_closed if true, will include closed issue. if
    #   false or missing, the result will only include open issues
    # @return [IssueCollection] the list of issues and pulls for the repo
    def issues_and_pulls(include_closed = false)
      @_issues_and_pulls ||= {}

      @_issues_and_pulls[include_closed] ||=
        IssueCollection.new(
          paginator_for_status(include_closed).to_a.flat_map do |gh|
            Issue.from_gh(org: @org, repo: @repo, gh: gh)
          end,
        )
    end

    # Get an IssuePaginator for a given open/closed issue status
    # @param [Boolean] include_closed if true, paginator will return results
    #   with closed issues. if false, closed issues will be excluded
    # @return [IssuePaginator] the issue paginator for this status and repo
    def paginator_for_status(include_closed)
      state_flag = include_closed ? 'all' : 'open'

      IssuePaginator.new(
        org: @org,
        repo: @repo,
        state: state_flag,
      )
    end

    # Get an array of label strings which are available on this repo
    # @return [Enumerable] a list of strings which are the names of labels
    #   available on this repo
    def labels
      @_labels ||=
        Github
        .issues.labels.list(@org, @repo, per_page: 100)
        .map(&:name)
        .map(&:downcase)
        .uniq
    end

    # Return a human readable description of the Repo model
    # @return [String] the human readable representation of the Repo model
    #   for the console
    def inspect
      "#<Hubkit::Repo:0x#{(object_id << 1).to_s(16)} #{@org}/#{@repo}>"
    end
  end
end
