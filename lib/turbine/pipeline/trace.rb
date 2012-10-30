module Turbine
  module Pipeline
    # Trace alters the pipeline such that instead of returning a single
    # "reduced" value each time the pipeline is run, an array is returned with
    # each element containing the result of each segment.
    #
    # See DSL#trace for more information.
    class Trace < Segment
      # Public: Sets the segment which serves as the source for the Trace.
      # Enables tracing on the source, and all of the parent sources.
      #
      # Returns the source.
      def source=(upstream)
        upstream.tracing = true
        super
      end

      # Public: Runs the pipeline once, returning the full trace which was
      # traversed in order to retrieve the value.
      #
      # Returns an object.
      def next
        @source.next
        @source.trace
      end
    end # Trace
  end # Pipeline
end # Turbine
