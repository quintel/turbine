module Turbine
  module Traversal
    # Traverses the graph breadth-first, following each item to its adjacent
    # items.
    #
    #        A
    #       / \
    #      B   C
    #     /   / \
    #    D   E   F
    #   /   /
    #  G   H
    #
    # In the above graph, using a breadth-first algorithm, starting from A,
    # the nodes are traversed in the order B -> C -> D -> E -> F -> G -> H.
    class BreadthFirst < Base

      #######
      private
      #######

      # Internal: Given a +node+ iterates through each of it's adjacent nodes
      # using the +method+ and +args+ supplied when initializing the
      # BreadthFirst instance.
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
        queue = node.public_send(@method, *@args).to_a.dup

        while item = queue.shift
          next if @seen[item]

          @seen[item] = true
          block.call(item)

          queue.push(*item.public_send(@method, *@args).to_a)
        end
      end

    end # BreadthFirst
  end # Traversal
end # Turbine
