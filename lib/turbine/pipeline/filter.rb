module Turbine
  module Pipeline
    # Emits only those values in the pipeline which satisfy the +filter+.
    # Filter is to Pipeline as +select+ is to Enumerable.
    #
    #   Filter.new { |x| firewall.permitted?(x) }
    #
    class Filter < Segment
      # Public: Creates a new Filter segment.
      #
      # You may opt to use the Filter class directly, passing a block when
      # initializing which is used to control which values are emitted.
      # Alternatively, provide no block and use a subclass with a custom
      # +filter+ method.
      #
      # Without a filter block, all elements are emitted.
      #
      # block - An optional block used to select which values are emitted by
      #         the filter.
      #
      # Returns a Filter.
      def initialize(&block)
        @filter = (block || method(:filter))
        super()
      end

      #######
      private
      #######

      # Internal: Handles each value from the pipeline, emitting only those
      # which satisfy the +filter+ block or method.
      #
      # value - The value being processed.
      #
      # Returns nothing.
      def handle_value(value)
        super if @filter.call(value)
      end

      # Internal: The default filter condition.
      #
      # Returns true or false.
      def filter(value)
        true
      end
    end # Filter
  end # Pipeline
end # Turbine
