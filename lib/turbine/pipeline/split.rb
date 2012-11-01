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
    class Split < Segment
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
        @branches = branches.each_with_object({}) do |branch, hash|
          dsl  = Pipeline.dsl([])
          pump = dsl.source

          hash[pump] = branch.call(dsl)
        end
      end

      #######
      private
      #######

      # Internal: Handles each value from the pipeline, passing it through
      # each of the +branches+ specified when the Split was created, emitting
      # the results of each branch in turn.
      #
      # Returns nothing.
      def handle_value(value)
        @branches.each do |pump, pipeline|
          pump.source = Array(value)
          pipeline.source.rewind

          pipeline.each { |entry| super(entry) }
        end
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
