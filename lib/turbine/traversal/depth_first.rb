module Turbine
  module Traversal
    # Traverses the graph depth-first, following each edge from a node to its
    # adjacent nodes, and to *their* adjacent nodes, etc...
    #
    #        A
    #       / \
    #      B   C
    #     /   / \
    #    D   E   F
    #   /   /
    #  G   H
    #
    # In the above graph, using a depth-first algorithm, starting from A,
    # the nodes are traversed in the order B -> D -> G -> C -> E -> H -> F.
    class DepthFirst < Base

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
        node.public_send(@method, *@args).each do |adjacent|
          next if @seen[adjacent]

          @seen[adjacent] = true
          block.call(adjacent)
          visit(fetch(adjacent), &block)
        end
      end

    end # DepthFirst
  end # Traversal
end # Turbine
