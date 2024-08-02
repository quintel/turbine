require 'set'

module Turbine
  module Algorithms
    # Internal: An implementation in ruby of Johnsons circuit finding algorithm.
    class Johnson
      # Discovered contains collections of nodes that create a circuit
      attr_reader :discovered

      # Filter should use the same tag used to tag circular edges. Circular edges need to be
      # tagged for a directed cyclic graph to pass Tarjan.
      def initialize(graph, &filter)
        @nodes = graph.nodes
        @filter = filter
        @stack = []
        @blocked = {}
        @blocked_map = @nodes.each_with_object({}) { |node, h| h[node] = Set.new }
        @discovered = [] # list of discovered circuits
      end

      # Main method for discovering circuits.
      #
      # Returns discovered circuits
      def discover_circuits
        start_pairs do |start_node, second_node|
          @start_node = start_node
          @stack.push(start_node)
          @blocked[start_node] = true

          clear_blocked
          circuit(second_node)

          @stack.pop
          @blocked[start_node] = false
        end

        @discovered
      end

      # Returns pairs with circular edge between them that serve as
      # starting points for the algorithm.
      #
      # We only have to use these starting points, and not need to check all
      # nodes, as it is a fact that each circuit contains at least one edge
      # labeled as circular. Otherwise, Tarjan would have failed in a previous
      # step.
      def start_pairs
        @nodes.each do |node|
          circ_edges = node.out_edges.select(&@filter)
          next if circ_edges.to_a.empty?

          circ_edges.each do |circ_edge|
            yield(node, circ_edge.nodes(:to))
          end
        end
      end

      private

      # Circuit procedure as in Johnson
      def circuit(node)
        f = false
        @stack.push(node)
        @blocked[node] = true

        node.out.each do |node_w|
          if node_w == @start_node
            save_circuit
            f = true
          elsif !@blocked[node_w]
            f = true if circuit(node_w)
          end
        end

        if f
          unblock(node)
        else
          node.out.each do |node_w|
            @blocked_map[node_w] << node
          end
        end
        @stack.pop

        f
      end

      # Unblock procedure as in Johnson
      def unblock(node)
        @blocked[node] = false
        @blocked_map[node].each { |node_w| unblock(node_w) if @blocked[node_w] }
        @blocked_map[node] = Set.new
      end

      # Adds the starting node to the stack, and adds the circuit to the discoveries
      #
      # The starting node is added, as this forces new object creation, and serves
      # edge finding later on.
      def save_circuit
        @discovered.push(@stack + [@start_node])
      end

      # Clears the blocked and blocked map (B in Johnson), for any nodes that have
      # not been used as a starting point.
      def clear_blocked
        starting_nodes = @discovered.map(&:first).uniq
        @nodes.each do |node|
          next if starting_nodes.include? node

          @blocked[node] = false
          @blocked_map[node] = Set.new
        end
      end
    end
  end
end
