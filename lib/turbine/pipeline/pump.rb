module Turbine
  module Pipeline
    # A pipeline segment which acts as the source for the pipeline. Values
    # from the pump are "piped" through each segment in the pipeline.
    class Pump < Segment
      # Public: Creates a new pump upon whose elements the pipeline will act.
      #
      # source - The elements in the source which will pass through the
      #          pipeline. Anything which responds to #each is acceptable,
      #          including arrays, Turbine collections, and enumerators.
      #
      # Returns a Pump.
      def initialize(source)
        @source = source
        super()
      end

      # Public: Iterates through each item in the source collection, yielding
      # the current fiber for each element in the source.
      #
      # Returns nothing.
      def process
        @source.each { |item| output(item) }
        nil
      end

      # Public: Rewinds the segment so that iteration can happen from the
      # first input again.
      #
      # Returns nothing.
      def rewind
        reset_fiber!
      end
    end # Pump
  end # Pipeline
end # Turbine
