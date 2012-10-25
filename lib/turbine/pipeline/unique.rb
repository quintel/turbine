module Turbine
  module Pipeline
    # A Pipeline segment which only emits values which it hasn't emitted
    # previously.
    #
    # In order to determine if a value is a duplicate, Unique needs to keep a
    # reference to each input it sees. For large result sets, you may prefer
    # to sacrifice performance for reduced space complexity by passing a
    # block; this used to reduce each input to a simpler value for storage and
    # comparison:
    #
    #   pipeline.uniq { |value| value.hash }
    #
    # See also: Array#uniq.
    class Unique < Filter

      # Public: Creates a new Unique segment.
      #
      # block - An optional block which is used to "reduce" each value for
      #         comparison with previously seen value.
      #
      # Returns a Unique.
      def initialize(&block)
        @seen = Set.new

        super do |value|
          key  = block ? block.call(value) : value
          seen = @seen.include?(key)

          @seen.add(key)

          not seen
        end
      end

      # Public: Rewinds the segment so that iteration can happen from the
      # first input again.
      #
      # Returns nothing.
      def rewind
        @seen.clear
        super
      end

    end # Unique
  end # Pipeline
end # Turbine
