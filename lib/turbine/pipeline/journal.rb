module Turbine
  module Pipeline
    # Journal segments keep track of all of the values emitted by the source
    # segment so that they can be used later in the pipeline.
    class Journal < Segment
      include Trace::Transparent

      # The name used to refer to the segments values later in the pipeline.
      attr_reader :name

      # Public: Creates a new Journal segment.
      #
      # name - A name which is associated with the values remembered by the
      #        segment. This is required so that the values can be referred to
      #        in later segments.
      #
      # Returns a Journal instance.
      def initialize(name)
        super()

        @name = name
        forget!
      end

      # Public: The values stored by the segment; contains the results of
      # running the upstream segments on all the inputs.
      #
      # Returns an array.
      def values
        @values ||= @source.to_a
      end

      # Public: Run the pipeline once, returning the next value. Forces
      # complete evalulation of the values emitted by the upstream segments.
      #
      # See Segment#next.
      #
      # Returns the next value.
      def next
        values
        super
      end

      # Public: Rewinds the segment so that iteration can happen from the
      # first in put again.
      #
      # Returns nothing.
      def rewind
        forget!
        super
      end

      # Public: Checks if the given +value+ is stored in the Journal. Faster
      # than +values.include?+.
      #
      # value - The value to look for.
      #
      # Returns true or false.
      def include?(value)
        @lookup ||= Set.new(values)
        @lookup.include?(value)
      end

      alias_method :member?, :include?

      # Public: Describes the segments through which each input will pass.
      #
      # Return a string.
      def to_s
        "#{ source_to_s } | as(#{ @name.inspect })"
      end

      #######
      private
      #######

      # Internal: Resets the Journal so that previously computed values are
      # forgotten.
      #
      # Returns nothing.
      def forget!
        @values = nil
        @lookup = nil
        @index  = -1
      end

      # Internal: Retrieves the next value emitted by the upstream segment.
      #
      # Returns an object.
      def input
        @values[@index += 1]
      end

      # A collection of methods providing segment classes with the means to
      # easily access values stored in an upstream Journal.
      module Read
        # Public: Retrieves the values stored in the upstream journal whose
        # name is +name+.
        #
        # name - The name of the upstream journal.
        #
        # Raises a NoSuchJournalError if the given +name+ does not match a
        # journal in the pipeline.
        #
        # Returns an array of values.
        def journal(name)
          upstream = source

          while upstream.kind_of?(Segment)
            if upstream.is_a?(Journal) && upstream.name == name
              return upstream
            end

            upstream = upstream.source
          end

          raise NoSuchJournalError.new(name)
        end
      end # Read
    end # Journal
  end # Pipeline
end # Turbine
