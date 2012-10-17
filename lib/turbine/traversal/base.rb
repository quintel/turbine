module Turbine
  module Traversal
    # Provides the means for traversing through the graph.
    #
    # Traversal classes do not themselves provide the methods commonly used
    # for iterating through collections (each, map, etc), but act as a
    # generator for the values in an Enumerator.
    #
    #   enumerator = DepthFirst.new(node, :in).to_enum
    #   # => #<Enumerator: Node, Node, ...>
    #
    #   enumerator.each { |node| ... }
    #   enumerator.map  { |node| ... }
    #   # etc ...
    #
    # The Base class should not be used directly, but instead you should use
    # DepthFirst or BreadthFirst which define strategies for the order in
    # which items are traversed.
    #
    # Each unique item is traversed a maximum of once (loops are not
    # repeatedly followed).
    #
    # Traversals are normally used to iterate through nodes, however you may
    # also use them to traverse edges by providing a +fetcher+ argument which
    # tells the traversal how to reach the next set of adjacent items:
    #
    #   DepthFirst.new(node, :in_edges, [], :out).to_enum
    #   # => #<Enumerator: Edge, Edge, ...>
    #
    # As an end-user, you should rarely have to instantiate a traversal class
    # yourself; Node#ancestors and Node#descendants provide a more convenient
    # short-cut.
    class Base
      # Creates a new graph traversal.
      #
      # start   - The node from which to start traversing.
      # method  - The method to be used to fetch the adjacent nodes (typically
      #           +in+ or +out+).
      # args    - Additional arguments to be used when calling +method+.
      # fetcher - An optional method name to be called on each adjacent item
      #           in order to fetch *its* adjacent items. Useful if traversing
      #           edges instead of nodes.
      #
      # Returns a new traversal.
      def initialize(start, method, args = nil, fetcher = nil)
        @start   = start
        @method  = method
        @args    = args
        @fetcher = fetcher
      end

      # Public: A human-readable version of the traversal.
      #
      # Returns a string.
      def inspect
        "#<#{ self.class.name } start=#{ @start.inspect } " \
          "method=#{ @method.inspect }" \
          "#{ @fetcher ? " fetcher=#{ @fetcher.inspect }" : '' }>"
      end

      # Public: The next node in the traversal.
      #
      # Raises a StopIteration if all reachable nodes have been visited.
      #
      # For example
      #
      #   traversal.next # => #<Turbine::Node key=:one>
      #   traversal.next # => #<Turbine::Node key=:two>
      #   traversal.next # => ! StopIteration
      #
      # Returns a Node.
      def next
        @fiber.resume
      end

      # Public: The traversal as an enumerator. This is the main way to
      # traverse since the enumerator implements +each+, +map+, +with_index+,
      # etc.
      #
      # Returns an Enumerator.
      def to_enum
        Enumerator.new do |control|
          rewind
          loop { control.yield(self.next) }
        end
      end

      #######
      private
      #######

      # Internal: Given a +node+ iterates through each of it's adjacent nodes
      # using the +method+ and +args+ supplied when initializing the
      # DepthFirst instance.
      #
      # When the node itself has matching adjacent nodes, those will also be
      # visited. If there are loops within the graph, they will not be
      # followed; each node is visited no more than once.
      #
      # node  - The node from which to traverse.
      # block - A block executed for each matching node.
      #
      # Returns nothing.
      def visit(node, &block)
        raise NotImplementedError, 'Define visit in a subclass'
      end

      # Internal: Fetches the next iteration item. If the traversal was
      # initialized with a +fetcher+, this is called on the item, otherwise
      # the item is returned untouched.
      #
      # Useful when traversing edges instead of nodes.
      #
      # Returns an object.
      def fetch(adjacent)
        @fetcher ? adjacent.public_send(@fetcher) : adjacent
      end

      # Internal: Resets the traversal to restart from the beginning.
      #
      # Returns nothing.
      def rewind
        @seen = { @start => true }

        @fiber = Fiber.new do
          visit(@start) { |*args| Fiber.yield(*args) }
          raise StopIteration
        end
      end

    end # Base
  end # Traversal
end # Turbine
