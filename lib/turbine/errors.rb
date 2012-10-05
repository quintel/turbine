module Turbine
  # An error class which serves as a base for all errors which occur in
  # Turbine.
  TurbineError = Class.new(StandardError)

  # Raised when adding a vertex to a graph, when one already exists with the
  # same key.
  class DuplicateVertex < TurbineError
    def initialize(key)
      @key = key
    end

    def message
      "Graph already has a vertex with the key #{ @key.inspect }"
    end
  end # DuplicateVertex
end # Turbine
