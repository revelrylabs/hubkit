# A class which implements an Enumerable which yields each resource returned
# by GitHub in turn, and handles the pagination for you (acts like a flat array,
# not an array of pages)
module Hubkit
  class Paginator
    include Enumerable

    def initialize(&block)
      @block = block
    end

    def each
      i = 1
      loop do
        results = @block.call i
        results.each do |result|
          yield result
        end
        i += 1
        break if results.length == 0
      end
    end
  end
end
