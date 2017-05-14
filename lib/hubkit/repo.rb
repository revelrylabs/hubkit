# Represents one GitHub repo
module Hubkit
  class Repo
    attr_accessor :org, :repo

    def self.list(visibility='all')
      RepoCollection.new(
        RepoPaginator
          .new(visibility)
          .map { |repo| { org: repo.owner.login, repo: repo.name } }
          .map { |params| new(**params) }
      )
    end

    def self.from_gh(gh)
      new(org: gh['owner']['login'], repo: gh.name)
    end

    def self.from_name_with_default_org(name)
      fail('Hubkit::Configuration.default_org is not set') if Hubkit::Configuration.default_org.nil?
      return from_name(name) if name.include?('/')
      from_name "#{Hubkit::Configuration.default_org}/#{name}"
    end

    def self.from_name(name)
      org, repo = name.split('/')
      self.new(org: org, repo: repo)
    end

    def initialize(org:, repo:)
      @org = org
      @repo = repo
    end

    def issues(include_closed = false)
      issues_and_pulls(include_closed).true_issues
    end

    delegate :pulls, to: :issues_and_pulls

    def issues_and_pulls(include_closed = false)
      @_issues_and_pulls ||= {}

      @_issues_and_pulls[include_closed] ||=
        IssueCollection.new(
          paginator_for_status(include_closed).to_a.flat_map do |gh|
            Issue.from_gh(org: @org, repo: @repo, gh: gh)
          end,
        )
    end

    def paginator_for_status(include_closed)
      state_flag = include_closed ? 'all' : 'open'

      IssuePaginator.new(
        org: @org,
        repo: @repo,
        state: state_flag,
      )
    end

    def labels
      @_labels ||=
        Github
        .issues.labels.list(@org, @repo, per_page: 100)
        .map(&:name)
        .map(&:downcase)
        .uniq
    end

    def inspect
      "#<Hubkit::Repo:0x#{(object_id << 1).to_s(16)} #{@org}/#{@repo}>"
    end
  end
end
