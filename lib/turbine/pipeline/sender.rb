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
    # continuing with the next input. See Expander for more details.
    class Sender < Expander
      attr_reader :message, :args

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

      # Public: Describes the segments through which each input will pass.
      #
      # Returns a string.
      def to_s
        "#{ source_to_s } | #{ message.to_s }" \
          "(#{ args.map(&:inspect).join(', ') })"
      end

      #######
      private
      #######

      def input
        super.public_send(@message, *args)
      end

    end # Sender
  end # Pipeline
end # Turbine
