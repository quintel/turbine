module Turbine
  module Pipeline
    # A segment which transforms its input by sending a +message+ to each
    # input and returning the result.
    #
    #   ( Pump.new([1, 2]) | Sender.new(:to_s) ).to_a
    #   # => ['1', '2']
    #
    # Each item coming from the source segment must have a public method with
    # the same name as the +message+.
    #
    # Some methods in Turbine return an Array, Collection, or Enumerator as a
    # sort of "result set" -- such as Node#in, Node#descendants, etc. In these
    # cases, each element in the result set is yielded separately before
    # continuing with the next input.
    #
    #   pump     = Pump.new(['abc def', 'hij klm'])
    #   split    = Sender.new(:split, ' ')
    #
    #   pipeline = pump | split
    #
    #   pipeline.next # => 'abc'
    #   pipeline.next # => 'def'
    #   pipeline.next # => 'hij'
    #   pipeline.next # => 'klm'
    class Sender < Segment

      # Public: Creates a new Sender segment.
      #
      # message - The message (method name) to be sent to each value in the
      #           pipeline.
      # args    - Optional arguments to be sent with the message.
      #
      # Returns a Sender.
      def initialize(message, *args)
        @message = message
        @args    = args

        super()
      end

      #######
      private
      #######

      def process
        while value = input.public_send(@message, *@args)
          case value
          when Array, Enumerator, Collection
            # Recurse into arrays as the input may return multiple results (as
            # is commonly the case when calling Node#in, Node#ancestors, etc).
            value.each { |buffered_value| handle_value(buffered_value) }
          else
            handle_value(value)
          end
        end
      end

    end # Sender
  end # Pipeline
end # Turbine
