module Turbine
  module Pipeline
    # A Pipeline segment which expands arrays, sets, and enumerators such
    # that, instead of sending them to the next segment, each member of the
    # collection is sent separately.
    #
    #   pump   = Pump.new(%w( abc def ), %w( hik klm ))
    #   expand = Expander.new
    #
    #   pipeline = pump | expand
    #
    #   pipeline.next # => 'abc'
    #   pipeline.next # => 'def'
    #   pipeline.next # => 'hij'
    #   pipeline.next # => 'klm'
    #
    # Using Expander on a pipeline has the same effect as calling +flatten(1)+
    # on an Array.
    class Expander < Segment

      # Public: Creates a new Expander segment.
      #
      # Returns an Expander.
      def initialize
        super
        @buffer = nil
      end

      # Public: Runs the pipeline once returning the next value.
      #
      # If a recent call to +next+ returned an array, set or enumerator, the
      # next value from that collection will be emitted instead. Only once all
      # of the values in the buffer have been emitted will the upstream
      # segment be called again.
      #
      # Returns an object.
      def next
        if from_buffer = input_from_buffer
          handle_value(from_buffer)
        else
          case value = super
          when Array, Set, Enumerator
            # Recurse into arrays, as the input may return multiple results (as
            # is commonly the case when calling Node#in, Node#descendants, etc).
            @buffer = value.to_a.compact
            @buffer.any? ? handle_value(@buffer.shift) : self.next
          else
            handle_value(value)
          end
        end
      end

      #######
      private
      #######

      # Internal: If there are any buffered values yet to be emitted, returns
      # the next one; otherwise returns nil.
      #
      # Returns an object or nil.
      def input_from_buffer
        @buffer && @buffer.any? && @buffer.shift
      end

    end # Expander
  end # Pipeline
end # Turbine
