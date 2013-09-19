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
      # node's adjacent "in" nodes, and their adjacent "in" nodes, and so on.
      #
      # label - An optional label which is used to restrict the edges
      #        traversed to those with the label.
      #
      # Returns a new DSL.
      def ancestors(label = nil)
        append(Traverse.new(:in, label))
      end

      # Public: Using the breadth-first traversal strategy, fetches all of a
      # node's adjacent "out" nodes, and their adjacent "out" nodes, and so
      # on.
      #
      # label - An optional label which is used to restrict the edges
      #         traversed to those with the label.
      #
      # Returns a new DSL.
      def descendants(label = nil)
        append(Traverse.new(:out, label))
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

      # Public: Splits the pipeline into separate branches, computes the
      # values from each branch in turn, then combines the results.
      #
      # branches - One or more blocks which will be given the DSL.
      #
      # For example
      #
      #    nodes.split(->(x) { x.get(:gender) },
      #                ->(x) { x.in_edges.length },
      #                ->(x) { x.out_edges.length }).to_a
      #    # => [ :male, 2, 3, :female, 1, 6, :female, 2, 2, ... ]
      #
      # Returns a new DSL.
      def split(*branches)
        append(Split.new(*branches))
      end

      # Public: Like +split+, but also yields the input value before running
      # each branch.
      #
      # branches - One or more blocks which will be given the DSL.
      #
      # For example
      #
      #   # Yields each node, and their outwards nodes connected with a
      #   # :spouse edge.
      #   nodes.also(->(node) { node.out(:spouse) })
      #
      # If you only want to supply a single branch, you can pass a block
      # instead.
      #
      #   nodes.also { |node| node.out(:child) }
      #
      # Returns a new DSL.
      def also(*branches, &block)
        append(Also.new(*branches, &block))
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

      # Public: Creates a filter so that only values which were present in a
      # named journal (created using "as") are emitted.
      #
      # journal_name - The name of the "as" journal.
      #
      # For example
      #
      #   # Did your grandparents "friend" your parents?
      #   node.in(:child).as(:parents).in(:child).out(:friend).only(:parents)
      #
      # Returns a new DSL.
      def only(journal_name)
        append(JournalFilter.new(:only, journal_name))
      end

      # Public: Creates a filter so that only values which were not present in
      # a named journal (created using "as") are emitted.
      #
      # name - The name of the "as" journal.
      #
      #   # Who are your uncles and aunts?
      #   node.in(:child).as(:parents).in(:child).out(:child).except(:parents)
      #
      # Returns a new DSL.
      def except(journal_name)
        append(JournalFilter.new(:except, journal_name))
      end

      # Public: Mutates the pipeline so that instead of returning a single
      # value, it returns an array where each element is the result returned
      # by each segment in the pipeline.
      #
      # Does not work correctly with pipelines where +descendants+ or
      # +ancestors+ is used before +trace+.
      #
      # For example
      #
      #   jay.out(:child).out(:child).trace.to_a
      #   # => [ [ #<Node key=:jay>, #<Node key=:claire>, #<Node key=:haley> ],
      #   #      [ #<Node key=:jay>, #<Node key=:claire>, #<Node key=:alex> ],
      #   #      ... ]
      #
      # This can be especially useful if you explicitly include edges in your
      # pipeline:
      #
      #   jay.out_edges(:child).in.out_edges(:child).in.trace.next
      #   # => [ [ #<Node key=:jay>,
      #   #        #<Edge :jay -:child-> :claire>,
      #   #        #<Node key=:claire>,
      #   #        #<Edge :claire -:child-> :haley>,
      #   #        #<Node key=:haley> ],
      #   #      ... ]
      #
      # Returns a new DSL.
      def trace
        DSL.new(@source.append(Trace.new))
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
