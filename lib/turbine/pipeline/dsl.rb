module Turbine
  module Pipeline
    # Public: Starts a new Pipeline chain using the given +source+ as the
    # source.
    #
    # source - An object, or array of objects, which will be iterated through
    #          the pipeline.
    #
    # Returns a DSL.
    def self.dsl(source)
      DSL.new(Pump.new(Array(source)))
    end

    # Provides the chaining DSL used throughout Turbine, such as when calling
    # Node#in, Node#descendants, etc.
    class DSL
      extend  Forwardable
      include Enumerable

      def_delegators :@source, :to_a, :each, :to_s

      # The final segment in the pipeline.
      attr_reader :source

      # Public: Creates a new DSL instance.
      #
      # source - A Segment which acts as the head of the pipeline. Normally
      #          an instance of Pump.
      #
      # Returns a DSL.
      def initialize(source)
        @source = source
      end

      # Public: Queries each input for its +key+ property. Expects the input
      # to include Turbine::Properties.
      #
      # key - The property key to be queried.
      #
      # For example
      #
      #   pipe.get(:age) # => [11, 15, 18, 44, 46]
      #
      # Returns a new DSL.
      def get(key)
        append(Sender.new(:get, key))
      end

      # Public: Retrieves the in_edges from the input nodes.
      #
      # label - An optional label; only edges with a matching label will be
      #         emitted by the pipeline.
      #
      # Returns a DSL.
      def in_edges(label = nil)
        append(Sender.new(:edges, :in, label))
      end

      # Public: Retrieves the out_edges from the input nodes.
      #
      # label - An optional label; only edges with a matching label will be
      #         emitted by the pipeline.
      #
      # Returns a new DSL.
      def out_edges(label = nil)
        append(Sender.new(:edges, :out, label))
      end

      # Public: Retrieves the inbound nodes on the input node or edge.
      #
      # label - An optional label; only edges connected to the node via an
      #         edge with this label will be emitted by the pipeline.
      #
      # Returns a new DSL.
      def in(label = nil)
        append(Sender.new(:nodes, :in, label))
      end

      # Public: Retrieves the outbound nodes on the input node or edge.
      #
      # label - An optional label; only edges connected to the node via an
      #         edge with this label will be emitted by the pipeline.
      #
      # Returns a new DSL.
      def out(label = nil)
        append(Sender.new(:nodes, :out, label))
      end

      # Public: Using the breadth-first traversal strategy, fetches all of a
      # node's adjacent nodes, and their adjacent nodes, and so on, in a given
      # +direction+
      #
      # direction - In which direction from the current node do you wat to
      #             traverse? :in or :out?
      # label     - An optional label which is used to restrict the edges
      #             traversed to those with the label.
      #
      # For example
      #
      #   # Fetches all nodes via outgoing edges.
      #   dsl.traverse(:out).to_a
      #
      #   # Gets all out nodes via edges which have the :child label.
      #   dsl.traverse(:out, :child)
      #
      # Returns a new DSL.
      def traverse(direction, label = nil)
        transform = Transform.new do |node|
          Traversal::BreadthFirst.new(node, direction, [label]).to_enum
        end

        DSL.new(@source.append(transform).append(Expander.new))
      end

      # Public: Given a block, emits input elements for which the block
      # evaluates to true.
      #
      # block - A block used to determine which element are emitted.
      #
      # Returns a new DSL.
      def select(&block)
        append(Filter.new(&block))
      end

      # Public: Given a block, emits input elements for which the block
      # evaluates to false.
      #
      # block - A block used to determine which elements are emitted.
      #
      # Returns a new DSL.
      def reject(&block)
        append(Filter.new { |value| ! block.call(value) })
      end

      # Public: Given a block, transforms each input value to the result of
      # running the block with the input.
      #
      # block - A block used to transform each input value.
      #
      # Returns a new DSL.
      def map(&block)
        append(Transform.new(&block))
      end

      # Public: Captures all of the values emitted by the previous segment so
      # that a later segment (e.g. "only" or "except") can use them.
      #
      # name - A name assigned to the captured values.
      #
      # Returns a new DSL.
      def as(name)
        append(Journal.new(name))
      end

      # Public: Filters each value so that only unique elements are emitted.
      #
      # block - An optional block used when determining if the value is
      #         unique. See Pipeline::Unique#initialize.
      #
      # Returns a new DSL.
      def uniq(&block)
        append(Unique.new(&block))
      end

      # Public: Creates a new DSL by appending the given +downstream+ segment
      # to the current source.
      #
      # downstream - The segment to be added in the new DSL.
      #
      # Returns a new DSL.
      def append(downstream)
        DSL.new(@source.append(downstream))
      end

      # Public: A human-readable version of the DSL.
      #
      # Return a String.
      def inspect
        "#<#{ self.class.inspect } {#{ to_s }}>"
      end
    end # DSL
  end # Pipeline
end # Turbine
