# A collection of Repos with chainable filters
module Hubkit
  class RepoCollection < ChainableCollection
    scope :organization do |x|
      @inner.select do |repo|
        repo['owner']['login'] == x
      end
    end

    scope :fork do
      wrap(@inner.select { |repo| repo['fork'] })
    end
  end
end
