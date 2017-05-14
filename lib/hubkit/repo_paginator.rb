# Retrieves all visible repos in one flat array, handling GitHub pagination
module Hubkit
  class RepoPaginator < Paginator
    include Enumerable

    def initialize(visibility='all')
      super() do |i|
        Cooldowner.with_cooldown do
          Hubkit.client.repos.list(visibility: visibility, page: i)
        end
      end
    end
  end
end
