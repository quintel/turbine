module Turbine
  module Pipeline
    # A segment which transforms the input into something else. For example,
    # a simple transform might receive an integer and output it's square root.
    #
    #   Transform.new { |x| Math.sqrt(x) }
    #
    class Transform < Segment
      # Public: Creates a new Transform element.
      #
      # You may opt to use the Transform class directly, passing a block when
      # initializing which is used to transform each value into something
      # else. Alternatively, provide no block and use a subclass with a custom
      # +transform+ method.
      #
      # Without a filter block, all elements are emitted.
      #
      # block - An optional block used to transform each value passing through
      #         the pipeline into something else.
      #
      # Returns a transform.
      def initialize(&block)
        @transform = (block || method(:transform))
        super()
      end

      #######
      private
      #######

      # Internal: Handles each value from the pipeline, using the +transform+
      # block or method to convert it into something else.
      #
      # value - The value being processed.
      #
      # Returns nothing.
      def handle_value(value)
        super(@transform.call(value))
      end

      # Internal: The default transform.
      #
      # Returns the +value+ untouched.
      def transform(value)
        value
      end
    end # Transform
  end # Pipeline
end # Turbine
