module Turbine
  module Pipeline
    # Splits the upstream source into multiple pipelines which are evaluated
    # in turn on the source, with the combined results being emitted.
    #
    # For example
    #
    #   pump  = Pump.new([node1, node2, node3])
    #   split = Split.new(->(x) { x.get(:age) },
    #                     ->(x) { x.get(:gender) })
    #
    #   (pump | split).to_a # => [ 18, :male, 27, :female, 25, :male ]
    #
    # You may supply as many separate branches as you wish.
    class Split < Expander
      Branch = Struct.new(:pump, :pipe)

      # Public: Creates a new Split segment.
      #
      # branches - One or more procs; each proc is given a new pipeline DSL so
      #            that you may transform / filter the inputs before the
      #            results are merged back into the output.
      #
      # Returns a new Split.
      def initialize(*branches)
        if branches.none?
          raise ArgumentError, 'Split requires at least one proc'
        end

        super()

        # Each DSL is evaluated once, and +handle_result+ changes the source
        # for each value being processed. This is more efficient than creating
        # and evaluating a new DSL for every input.
        @branches = branches.map do |branch|
          dsl  = Pipeline.dsl([])
          pump = dsl.source

          Branch.new(pump, branch.call(dsl))
        end

        # JRuby doesn't support calling +next+ on enum.cycle.with_index.
        @branches_cycle = @branches.zip((0...@branches.length).to_a).cycle
      end

      # Public: Returns the trace containing the most recently emitted values
      # for all source segments. The trace for the current branch pipeline is
      # merged into the trace.
      #
      # See Segment#trace.
      #
      # Returns an array.
      def trace
        super { |trace| trace.push(*@previous_trace) }
      end

      # Public: Enables or disables tracing on the segment. Passes the boolean
      # through to the internal branch pipelines also, so that their traces
      # may be combined with the output.
      #
      # Returns the tracing setting.
      def tracing=(use_tracing)
        super

        @branches.each do |branch|
          branch.pipe.source.tracing = use_tracing
        end
      end

      #######
      private
      #######

      # Internal: Returns the next value to be processed by the pipeline.
      #
      # Calling +input+ will fetch the input from the upstream segment,
      # process it on the first branch and return the value. The next call
      # will process the same input on the second branch, and so on util the
      # value has been passed through each branch. Only then do we fetch a new
      # input and start over.
      #
      # Returns an object.
      def input
        branch, iteration = @branches_cycle.next

        # We've been through each branch for the current source, time to fetch
        # the next one?
        if (iteration % @branches.length).zero?
          @branch_source = Array(super).to_enum
        end

        branch.pump.source = @branch_source
        branch.pipe.source.rewind

        values = branch.pipe.to_a

        @previous_trace = branch.pipe.source.trace.drop(1) if @tracing

        values.any? ? values : input
      end
    end # Split

    # A special case of split which emits the input value, and the results
    # of a the given branches.
    #
    # For example
    #
    #   # Get your friends and their friends, and emit both as a single list.
    #   nodes.out(:friend).also(->(node) { node.out(:friend) })
    #
    class Also < Split
      # Creates a new Also segment.
      #
      # branches - A single branch whose results will be emitted along with
      #            the input value.
      #
      # For example
      #
      #   nodes.also(->(n) { n.out(:spouse) }, ->(n) { n.out(:child) })
      #
      # If you only need to supply a single branch, you can pass it as a block
      # instead of a proc wrapped in an array.
      #
      #   nodes.also { |n| n.out(:spouse) }
      #
      # Returns a new Also.
      def initialize(*branches, &block)
        super(*[->(node) { node }, *branches, block].compact)
      end
    end # Also
  end # Pipeline
end # Turbine
