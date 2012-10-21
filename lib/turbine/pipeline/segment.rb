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
        reset_fiber!
      end

      # Public: Describes the path which each input will take when passed
      # through the pipeline.
      #
      # For example:
      #
      #   pipeline.path
      #   # => "Pump | Sender(out) | Filter"
      #
      # Returns a string.
      def path
        name = self.class.name

        # Nicked from ActiveSupport since it's faster than gsub, and more
        # memory-efficient than split.
        name = (index = name.rindex('::')) ? name[(index + 2)..-1] : name

        if @source.respond_to?(:path)
          "#{ @source.path } | #{ name }"
        else
          name
        end
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

      def handle_value(value)
        Fiber.yield(value)
      end

      def reset_fiber!
        @fiber = Fiber.new { process ; raise StopIteration }
      end
    end # Segment
  end # Pipeline
end # Turbine
