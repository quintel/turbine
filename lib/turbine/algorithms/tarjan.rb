module Turbine
  module Algorithms
    # A wrapper around the Ruby stdlib implementation of Tarjan's strongly
    # connected components and topological sort.
    class Tarjan
      include TSort

      # Public: Creates a new Tarjan instance used for topologically sorting
      # graphs.
      #
      # graph - A Turbine graph whose nodes are to be sorted.
      # label - An optional label which will be used when traversing from a
      #         node to its +out+ nodes.
      #
      # For example
      #
      #   Turbine::Algorithms::Tarjan.new(graph).tsort
      #   # => [ [ #<Node key=one>, #<Node key=two>, #<Node key=three> ],
      #          [ #<Node key=five> ],
      #          [ #<Node key=six>, #<Node key=seven> ] ]
      #
      #   Turbine::Algorithms::Tarjan.new(graph, :spouse).tsort
      #   # => [ ... ]
      #
      # Returns a Tarjan.
      def initialize(graph, label = nil)
        @nodes = graph.nodes
        @label = label
      end

      #######
      private
      #######

      # Internal: Used by TSort to iterate through each node in the graph.
      #
      # Returns nothing.
      def tsort_each_node
        @nodes.each { |node| yield node }
      end

      # Internal: Used by TSort to iterate through each +out+ node.
      #
      # Returns nothing.
      def tsort_each_child(node)
        node.nodes(:out, @label).each { |out| yield out }
      end
    end # Tarjan
  end # Algorithms
end # Turbine
