module Hubkit
  # Retrieves all visible repos in one flat array, handling GitHub pagination
  class RepoPaginator < Paginator
    include Enumerable

    # Construct a new repo paginator
    # @param [optional String] visibility if missing or 'all', retrieves all
    #   repos. if 'public', only retrieves public repos
    def initialize(visibility='all')
      super() do |i|
        Cooldowner.with_cooldown do
          Hubkit.client.repos.list(visibility: visibility, page: i)
        end
      end
    end
  end
end
