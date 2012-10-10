module Turbine
  # An error class which serves as a base for all errors which occur in
  # Turbine.
  TurbineError = Class.new(StandardError)

  # Raised when adding a node to a graph, when one already exists with the
  # same key.
  class DuplicateNode < TurbineError
    def initialize(key)
      @key = key
    end

    def message
      "Graph already has a node with the key #{ @key.inspect }"
    end
  end # DuplicateNode

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
end # Turbine
