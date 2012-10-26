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

      #######
      private
      #######

      def handle_value(value)
        case value
        when Array, Set, Enumerator, Collection
          # Recurse into arrays, as the input may return multiple results (as
          # is commonly the case when calling Node#in, Node#descendants, etc).
          value.each { |entry| super(entry) }
        else
          super(value)
        end
      end

    end # Expander
  end # Pipeline
end # Turbine
