module Turbine
  module Algorithms
    # Internal: A wrapper around the Ruby stdlib implementation of Tarjan's
    # strongly connected components and topological sort algorithms. Restricts
    # the sort to only those edges which match the filter.
    class FilteredTarjan < Tarjan

      # Public: Creates a FilteredTarjan instance. If you simply wish to
      # filter by the edge label, the standard Tarjan class will do this with
      # better performance.
      #
      # graph   - A Turbine graph whose nodes are to be sorted.
      # &filter - Block which sleects the edges used to perform the sort.
      #
      # Returns a FilteredTarjan.
      def initialize(graph, &filter)
        super(graph, nil)
        @filter = filter
      end

      #######
      private
      #######

      # Internal: Used by TSort to iterate through each +out+ node.
      #
      # Returns nothing.
      def tsort_each_child(node)
        node.out_edges.select(&@filter).each { |edge| yield edge.to }
      end
    end # FilteredTarjan
  end # Algorithms
end # Turbine
