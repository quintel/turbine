module Turbine
  module Pipeline
    # A filter which uses an upstream Journal as a basis for determining which
    # values should be emitted.
    class JournalFilter < Filter
      include Journal::Read

      # Public: Creates a new JournalFilter.
      #
      # mode - The filter mode to be used. :only will cause the filter to emit
      #        only values which were seen in the journal, while :except will
      #        emit only those which were *not* seen.
      # name - The name of the Journal whose values will be used.
      #
      # Returns a JournalFilter.
      def initialize(mode, name)
        unless mode == :only || mode == :except
          raise ArgumentError, 'JournalFilter mode must be :only or :except'
        end

        @mode = mode
        @journal_name = name

        super(&method(:"filter_#{ mode }"))
      end

      # Public: Sets the previous segment in the pipeline.
      #
      # Raises NoSuchJournalError if the Journal required by the filter is not
      # present in the source pipeline.
      #
      # Returns the source.
      def source=(source)
        super
        @journal = journal(@journal_name)
      end

      # Public: Describes the segments through which each input will pass.
      #
      # Return a string.
      def to_s
        "#{ source_to_s } | #{ @mode }(#{ @journal_name.inspect })"
      end

      #######
      private
      #######

      # Internal: Filter mode which emits only the values which were seen in
      # the journal.
      #
      # value - The value emitted by the source.
      #
      # Returns true or false.
      def filter_only(value)
        @journal.include?(value)
      end

      # Internal: Filter mode which emits only the values which were not seen
      # in the journal.
      #
      # value - The value emitted by the source.
      #
      # Returns true or false.
      def filter_except(value)
        not filter_only(value)
      end

    end # Only
  end # Pipeline
end # Turbine
