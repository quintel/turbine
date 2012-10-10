module Turbine
  # Contains nodes and edges.
  class Graph

    # Public: Creates a new graph.
    def initialize
      @nodes = {}
    end

    # Public: Adds the +node+ to the graph.
    #
    # node - The node to be added.
    #
    # Raises a DuplicateNode is the graph already contains a node with the
    # same key.
    #
    # Returns the node.
    def add_node(node)
      if @nodes.key?(node.key)
        raise DuplicateNode.new(node.key)
      end

      @nodes[node.key] = node
    end

    # Public: Retrieves the node whose key is +key+.
    #
    # key - The key of the desired node.
    #
    # Returns the node, or nil if no such node is known.
    def node(key)
      @nodes[key]
    end

    # Public: All of the nodes in an array.
    #
    # Generally speaking, the nodes will be returned in the same order as
    # they were added to the graph, however this may very depending on your
    # Ruby implementation.
    #
    # Returns an array of nodes.
    def nodes
      @nodes.values
    end

    # Public: A human-readable version of the graph.
    def inspect
      "#<Turbine::Graph (#{ @nodes.length } nodes)>"
    end

  end # Graph
end # Turbine
