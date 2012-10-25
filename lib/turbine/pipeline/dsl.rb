module Turbine
  module Pipeline
    # Public: Starts a new Pipeline chain using the given +source+ as the
    # source.
    #
    # source - An object, or array of objects, which will be iterated through
    #          the pipeline.
    #
    # Returns a DSL.
    def self.dsl(source)
      DSL.new(Pump.new(Array(source)))
    end

    # Provides the chaining DSL used throughout Turbine, such as when calling
    # Node#in, Node#descendants, etc.
    class DSL
      extend Forwardable

      # Public: Methods which, when called on the DSL object, create a Sender
      # segment which calls the method of the same name on each input.
      #
      # name - The method name.
      #
      # Returns nothing.
      def self.sender_method(name)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ name }(*args)
            DSL.new(@source.append(Sender.new(:#{ name }, *args)))
          end
        RUBY
      end

      def_delegators :@source, :to_a, :each, :to_s

      # The final segment in the pipeline.
      attr_reader :source

      # Public: Creates a new DSL instance.
      #
      # source - A Segment which acts as the head of the pipeline. Normally
      #          an instance of Pump.
      #
      # Returns a DSL.
      def initialize(source)
        @source = source
      end

      sender_method :ancestors
      sender_method :descendants
      sender_method :get
      sender_method :in
      sender_method :in_edges
      sender_method :out
      sender_method :out_edges

      # Public: Given a block, emits input elements for which the block
      # evaluates to true.
      #
      # block - A block used to determine which element are emitted.
      #
      # Returns a new DSL.
      def select(&block)
        DSL.new(@source.append(Filter.new(&block)))
      end

      # Public: Given a block, emits input elements for which the block
      # evaluates to false.
      #
      # block - A block used to determine which elements are emitted.
      #
      # Returns a new DSL.
      def reject(&block)
        DSL.new(@source.append(Filter.new { |value| ! block.call(value) }))
      end

      # Public: Given a block, transforms each input value to the result of
      # running the block with the input.
      #
      # block - A block used to transform each input value.
      #
      # Returns a new DSL.
      def map(&block)
        DSL.new(@source.append(Transform.new(&block)))
      end
    end # DSL
  end # Pipeline
end # Turbine
