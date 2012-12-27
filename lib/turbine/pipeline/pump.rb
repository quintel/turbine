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
        @source = source.to_enum
        super()
      end
    end # Pump
  end # Pipeline
end # Turbine
