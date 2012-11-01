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

      # When included into a segment, sets it so that the value emitted by the
      # segment is not included in traces. Useful for filters which would
      # otherwise result in a duplicate value in the trace.
      module Transparent
        # Public: Trace each transformation made to an input value.
        #
        # See Segment#trace.
        #
        # Returns an array.
        def trace
          @source.trace
        end
      end # Transparent

      # When included into a segment, raises an error if the user tries to
      # enable tracing.
      module Untraceable
        # Public: Enable or disable tracing on the segment. Raises a
        # NotTraceableError when called with a truthy value.
        #
        # Returns the tracing setting.
        def tracing=(use_tracing)
          raise NotTraceableError.new(self) if use_tracing
          super
        end
      end # Untraceable
    end # Trace
  end # Pipeline
end # Turbine
