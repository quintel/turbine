module Turbine
  module Pipeline
    # Represents a single stage in a pipeline. A pipeline may contain many
    # segments, each of which transform or filter the elements which pass
    # through it.
    class Segment
      include Enumerable

      # The previous segment in the pipeline.
      attr_accessor :source

      # Public: Creates a new Segment. Segment itself is of little value in
      # your pipelines as it will simply emit every value it is given. Instead
      # you should look to Pump, Transform, and Filter.
      #
      # Returns a Segment.
      def initialize
        reset_fiber!
        @tracing = false
      end

      # Public: Appends +other+ segment to be given the values emitted by this
      # segment. Instead of a Segment instance, a block can be given instead
      # which is used as a Transform.
      #
      # other - The segment or transform block to be run after this segment.
      #
      # For example, transforming three numbers using a Transform segment:
      #
      #   Pump.new([10, 20, 30]).append(Transform.new { |x| Math.sqrt(x) })
      #
      # Or using a lambda:
      #
      #   Pump.new([10, 20, 30]).append(->(x) { x ** 10 })
      #
      # Or using Dave Thomas' pipes syntax:
      #
      #   pump       = Pump.new((100..10000).to_a)
      #   divide     = Transform.new { |x| x / 100 }
      #   the_answer = Filter.new { |x| x == 42 }
      #
      #   (pump | divide | the_answer).next # => 42
      #
      # Returns the +other+ segment.
      def append(other)
        if other.respond_to?(:call)
          other = Transform.new(&other)
        end

        other.source = self
        other
      end

      alias_method :|, :append

      # Public: Runs the pipeline once, returning the next value. Repeatedly
      # calling this will yield each value in turn. Once all values have been
      # emitted a StopIteration is raised (mimicking the behaviour of
      # Enumerator).
      #
      # Returns an object.
      def next
        @fiber.resume
      end

      # Public: Iterates through each value in the pipeline.
      #
      # Returns nothing.
      def each
        rewind
        loop { yield self.next }
      end

      # Public: Rewinds the segment so that iteration can happen from the
      # first input again.
      #
      # Returns nothing.
      def rewind
        @source.rewind
        @previous = nil
        reset_fiber!
      end

      # Public: Enables tracing on the segment and it's source. This tells the
      # segment to keep track of the most recently emitted value for use in a
      # subsequent Trace segment.
      #
      # Returns the tracing setting.
      def tracing=(use_tracing)
        @tracing = use_tracing

        if @source && @source.respond_to?(:tracing=)
          @source.tracing = use_tracing
        end
      end

      # Public: Returns the trace containing the most recently emitted values
      # for all the source segments, appending this segment's value to the end
      # of the array.
      #
      # For example
      #
      #   segment.next && segment.trace
      #   # => [[ #<Node key=:jay>, #<Node key=:claire>, #<Node key=:haley> ]]
      #
      #   segment.next && segment.trace
      #   # => [[ #<Node key=:jay>, #<Node key=:claire>, #<Node key=:alex> ]]
      #
      # Tracing must be enabled (normally by appending a Trace segment to the
      # pipeline) otherwise a TracingNotEnabledError is raised.
      #
      # Subclasses may call +super+ with a block; the sole argument given to
      # the block will be trace from the source segments.
      #
      # Returns an array.
      def trace
        unless @tracing
          raise TracingNotEnabledError.new(self)
        end

        trace = @source.respond_to?(:trace) ? @source.trace.dup : []
        block_given? ? yield(trace) : trace.push(@previous)
      end

      # Public: Describes the segments through which each input will pass.
      #
      # For example:
      #
      #   pipeline.to_s
      #   # => "Pump | Sender(out) | Filter"
      #
      # Returns a string.
      def to_s
        name = self.class.name

        # Nicked from ActiveSupport since it's faster than gsub, and more
        # memory-efficient than split.
        name = (index = name.rindex('::')) ? name[(index + 2)..-1] : name

        source_string = source_to_s
        source_string.nil? ? name : "#{ source_string } | #{ name }"
      end

      # Public: A human-readable version of the segment for debugging.
      #
      # Returns a String.
      def inspect
        to_s
      end

      #######
      private
      #######

      def process
        while value = input
          handle_value(value)
        end
      end

      def input
        source.next
      end

      def output(value)
        if @tracing
          @previous = value
        end

        Fiber.yield(value)
      end

      def handle_value(value)
        output(value)
      end

      def reset_fiber!
        @fiber = Fiber.new { process ; raise StopIteration }
      end

      def source_to_s
        @source.is_a?(Segment) ? @source.to_s : nil
      end
    end # Segment
  end # Pipeline
end # Turbine
