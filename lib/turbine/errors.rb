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
end # Turbine
