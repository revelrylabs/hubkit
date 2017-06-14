module Hubkit
  # @abstract A class which wraps an array (or Enumerable) and provides convenience
  # methods for chainable filters, e.g.:
  # @example
  #     repo.issues.unassigned.labeled('in progress')
  class ChainableCollection
    # Allows definition of new chainable filters within the class definition
    # @example
    #   scope :unlabeled, -> { |collection| collection.reject(&:labeled?) }
    # @param [String, Symbol] name the anem of the method
    # @yieldparam ... any arguments needed by the block
    def self.scope(name, &block)
      define_method name do |*args|
        wrap(
          instance_exec(*args, &block),
        )
      end
    end

    # Create a new ChainableCollection
    # @param [Enumerable] inner the collection which will be wrapped in the
    #   Hubkit::ChainableCollection
    def initialize(inner)
      @inner = inner
    end

    # Return a Hubkit::ChainableCollection containing all members for which
    # the block is true. This new Hubkit::ChainableCollection will also be
    # filterable in the same way.
    # @yieldparam item the item to be evaluated by the block
    def select(&block)
      return wrap(@inner.select &block) if block_given?
      wrap(@inner.select)
    end

    # Return a collection of the same type as `self`, containing `items`
    # @param [Enumberable] items the items to be contained in the new
    #   collection
    def wrap(items)
      self.class.new(items)
    end

    # Check if a method is implemented by either this method or the wrapped
    # collection
    # @param [String, Symbol] name the name of the method to check
    # @param [Boolean] include_all if true, will include private methods
    # @return [Boolean] returns true if the collection or the wrapped
    #   collection implements the method
    def respond_to?(name, include_all = false)
      super || @inner.respond_to?(name)
    end

    # Call into the wrapped collection if a method has not been implemented
    # on the ChainableCollection
    # @param [String, Symbol] name the name of the method being called
    # @param [Array] args the arguments to the method being called
    # @yieldparam ... the parameters of the any block given to the method
    #   which is being called
    # @return the value of the method on the inner collection as called
    def method_missing(name, *args, &block)
      return super unless @inner.respond_to?(name)
      @inner.send(name, *args, &block)
    end

    # Returns a collection which will contain all elements which are contained
    # in this ChainableCollection, but NOT matching any additional chained filters
    # @example
    #   ChainableCollection.new([1, 2, 3, 4]).not.select(&:odd?) # even->[2, 4]
    # @return [NotCollection] a collection which contains all elements of self
    #   which don't match additional filters
    def not
      NotCollection.new(self)
    end

    # Returns true if the other collection contains the same elements
    # @param [Enumerable] other collection to compare with
    # @return [Boolean] true if this collection and the other contain the same
    #   elements
    def ==(other)
      other == self.to_a
    end
  end

  # A collection that lets you perform the inverse of a filter
  # @example
  #     repo.issues.not.labeled('in progress')
  class NotCollection
    def initialize(base)
      @base = base
    end

    # Any method of this class will be delegated down to the original
    # ChainableCollection. The result of the method will be a
    # ChainableCollection which contains all the elements not returned
    # by the filter called.
    # @param [String, Symbol] name the name of the method being called
    # @param [Array] args the arguments to the method being called
    # @yieldparam ... the parameters of the any block given to the method
    #   which is being called
    # @return [ChainableCollection] all elements which do not match the chained
    #   filter in a new ChainableCollection
    def method_missing(name, *args, &block)
      @base.wrap(@base - @base.send(name, *args, &block))
    end
  end
end
