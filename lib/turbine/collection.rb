module Turbine
  # Collection wraps the results of Node#in and Node#out so that expressions
  # can be chained.
  #
  # It is similar to Haskell's "Maybe" or jQuery collections in that it may
  # contain zero or more elements, but will not return errors when running
  # methods on an empty collection.
  #
  # For example:
  #
  #   # All out edges except loss
  #   # -------------------------
  #
  #   converter.out - converter.out(:loss)
  #
  #   # Step-children
  #   # -------------
  #
  #   jay.out(:child) - jay.out(:spouse).out(:child)
  #
  #   # Uncles and aunts
  #   # ----------------
  #
  #   # Fetch Luke's grandparents, and then create a list containing their
  #   # children (which will include one of Luke's parents).
  #
  #   grandparents = luke.in(:child).in(:child)
  #   grandparent_children = grandparents.out(:child)
  #
  #   # Remove the Luke's parents:
  #
  #   grandparent_children = grandparent_children - luke.out(:parent)
  #
  #   # The collection now contains uncles and aunts who are direct relatives;
  #   # complete the list by adding their spouses:
  #
  #   grandparent_children + grandparent_children(:spouse)
  #
  #   # Filtering outputs
  #   # -----------------
  #
  #   # Here we grab node :g, and then select any out node whose key is either
  #   # :a, :b, or :c. Then, of those nodes which were matched, we select
  #   # *their* output nodes which are connected using an edge with the :gas
  #   # label. It doesn't matter if :a, :b, or :c don't exist, or if they
  #   # don't have a gas output; the expression will select only what matches
  #   # and ignore everything which doesn't.
  #
  #   converter = graph.node(:g)
  #   converter.out.select { |n| [:a, :b, :c].include?(n.key) }.out(:gas)
  #
  class Collection
    include Enumerable

    # Public: Creates a new Collection.
    #
    # collection - The original collection. This may be anything which
    #              implements +to_a+, but typically an array is expected.
    #              Duplicates are removed from the collection.
    #
    # Returns a Collection.
    def initialize(collection)
      @collection = Set.new(collection.to_a)
    end

    # Public: Iterates throuch each item in the collection. Used by
    # Enumerable.
    #
    # Returns nothing.
    def each(*args, &block)
      @collection.each(*args, &block)
    end

    # Public: Catches calls to methods which do not exist, and sends it so
    # each item in the collection.
    #
    # Returns a new Collection.
    def method_missing(method, *args, &block)
      new_collection = @collection.each_with_object(Set.new) do |item, set|
        set.merge(Array(item.public_send(method, *args, &block)))
      end

      Collection.new(new_collection)
    end

    # Public: A human-readable version of the collection.
    def inspect
      "#<Turbine::Collection {#{ @collection.map(&:inspect).join(', ') }}>"
    end

    # Public: The number of items in the collection.
    #
    # Returns an integer.
    def length
      @collection.length
    end

    # General Modifiers
    # -----------------

    # Public: Creates a new collection containing all of the elements from
    # +self+ and +other+, without any duplicated.
    #
    # other - An object which reponds to #to_a, whose elements are to be
    #         added to those from +self+ when creating the new collection.
    #
    # Returns a Collection.
    def +(other)
      Collection.new(@collection + other.to_a)
    end

    alias_method :|, :+

    # Public: Creates a new collection containing the elements from +self+,
    # minus those in +other+.
    #
    # other - An object which reponds to #to_a, whose elements are to be
    #         excluded from the new collection.
    #
    # Returns a Collection.
    def -(other)
      Collection.new(@collection - other.to_a)
    end

    # Public: Creates a new collection with only those elements which are
    # common to both +self+ and +other+.
    #
    # other - An object which reponds to #to_a, whose elements are to be
    #         tested against those in +self+.
    #
    # Returns a Collection.
    def &(other)
      Collection.new(@collection & other.to_a)
    end

    # Enumerable Overrides
    # --------------------
    #
    # Wrap around Enumerable methods to ensure that they return a Collection.
    # TODO: There are a lot of methods missing still missing.

    # Public: Creates a new collection containing only elements for which
    # +block+ is true.
    #
    # Returns a collection.
    def select(*args, &block)
      Collection.new(super(*args, &block))
    end

    alias_method :find_all, :select

    # Public: Creates a new collection excluding elements for which +block+ is
    # true.
    #
    # Returns a collection.
    def reject(*args, &block)
      Collection.new(super(*args, &block))
    end

    # Equality and Identity
    # ---------------------

    # Public: Tests if the contents of +other+ is identical to +self+.
    def equal?(other)
      other.is_a?(Collection) && @collection == Set.new(other.to_a)
    end

    alias_method :==, :equal?

    # Methods For Performance
    # -----------------------

    # Public: Performance improvement when using +flatten+ with
    # +method_missing+.
    #
    # Returns an array.
    def to_ary
      to_a
    end

    # Public: Returns the collection as an array.
    #
    # Returns an array.
    def to_a
      @collection.to_a
    end
  end # Collection
end # Turbine
