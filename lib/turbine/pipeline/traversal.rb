module Turbine
  module Pipeline
    class Traverse < Expander
      include Trace::Untraceable

      # Public: Creates a new Traverse segment. Uses one of the traversal
      # classes to emit every descendant of the input node.
      #
      # direction - The direction in which to traverse edges. :in or :out.
      # label     - An optional label by which to restrict the edges
      #             traversed.
      # klass     - The traversal strategy. Defaults to BreadthFirst.
      #
      # Returns a new Traverse.
      def initialize(direction, label = nil, klass = nil)
        @direction = direction
        @label     = label
        @klass   ||= Traversal::BreadthFirst
      end

      #######
      private
      #######

      # Public: Passes each value into a traversal class, emitting every
      # adjacent node.
      #
      # Returns nothing.
      def handle_value(value)
        super(@klass.new(value, @direction, [@label]).to_enum)
      end
    end # Traverse
  end # Pipeline
end # Turbine
