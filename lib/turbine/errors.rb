module Turbine
  # An error class which serves as a base for all errors which occur in
  # Turbine.
  TurbineError = Class.new(StandardError)

  # Raised when adding a node to a graph, when one already exists with the
  # same key.
  class DuplicateNodeError < TurbineError
    def initialize(key)
      @key = key
    end

    def message
      "Graph already has a node with the key #{ @key.inspect }"
    end
  end # DuplicateNodeError

  # Raised when adding an edge between two nodes which is too similar to an
  # existing edge. See Edge#similar?
  class EdgeTooSimilarError < TurbineError
    def initialize(node, edge)
      @node, @edge = node, edge
    end

    def message
      "Another edge already exists on #{ @node.inspect } which is too " \
      "similar to #{ @edge.inspect }"
    end
  end

  # Raised when setting properties on an object, and the given object is not a
  # hash, or is invalid in some way.
  class InvalidPropertiesError < TurbineError
    def initialize(model, properties)
      @model      = model
      @properties = properties
    end

    def message
      "Tried to assign properties #{ @properties.inspect } on " \
        "#{ @model.inspect } - it must be a Hash, or subclass of Hash."
    end
  end # InvalidPropertiesError

  # Raised when adding a second Edge from one Node to the Other.
  class DuplicateEdgeError < TurbineError
    def initialize
    end

    def message
      "Graph already has this edge defined"
    end
  end
end # Turbine
