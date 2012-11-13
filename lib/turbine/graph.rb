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
    # Raises a DuplicateNodeError if the graph already contains a node with
    # the same key.
    #
    # Returns the node.
    def add(node)
      if @nodes.key?(node.key)
        raise DuplicateNodeError.new(node.key)
      end

      @nodes[node.key] = node
    end

    # Public: Removes the +node+ from the graph and disconnects any nodes
    # which have edges to the +node+.
    #
    # node - The node to be deleted.
    #
    # Raises a NoSuchNodeError if the graph does not contain the given +node+.
    #
    # Returns the node.
    def delete(node)
      unless @nodes.key?(node.key)
        raise NoSuchNodeError.new(node.key)
      end

      (node.edges(:out) + node.edges(:in)).each do |edge|
        edge.from.disconnect_via(edge)
        edge.to.disconnect_via(edge)
      end

      @nodes.delete(node.key)
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

    # Public: Topologically sorts the nodes in the graph so that nodes with
    # no in edges appear at the beginning of the array, and those deeper
    # within the graph are at the end.
    #
    # label - An optional label used to limit the edges used when traversing
    #         from one node to its outward nodes.
    #
    # Raises CyclicError if the graph contains loops.
    #
    # Returns an array.
    def tsort(label = nil)
      Algorithms::Tarjan.new(self, label).tsort
    rescue TSort::Cyclic => exception
      raise CyclicError.new(exception)
    end

    # Public: Uses Tarjan's strongly-connected components algorithm to detect
    # nodes which are interrelated.
    #
    # label - An optional label used to limit the edges used when traversing
    #         from one node to its outward nodes.
    #
    # For example
    #
    #   graph.strongly_connected_components
    #   # => [ [ #<Node key=one> ],
    #          [ #<Node key=two>, #<Node key=three>, #<Node key=four> ],
    #          [ #<Node key=five>, #<Node key=six ] ]
    #
    # Returns an array.
    def strongly_connected_components(label = nil)
      Algorithms::Tarjan.new(self, label).strongly_connected_components
    end

    # Public: A human-readable version of the graph.
    #
    # Returns a string.
    def inspect
      edge_count = @nodes.values.each_with_object(Set.new) do |node, edges|
        edges.merge(node.edges(:out))
      end.length

      "#<#{self.class} (#{ @nodes.length } nodes, #{ edge_count } edges)>"
    end

  end # Graph
end # Turbine
