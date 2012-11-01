module Turbine
  # An error class which serves as a base for all errors which occur in
  # Turbine.
  TurbineError = Class.new(StandardError)

  # Raised when adding a node to a graph, when one already exists with the
  # same key.
  class DuplicateNodeError < TurbineError
    def initialize(key)
      super("Graph already has a node with the key #{ key.inspect }")
    end
  end # DuplicateNodeError

  # Raised when adding an edge between two nodes which is too similar to an
  # existing edge. See Edge#similar?
  class DuplicateEdgeError < TurbineError
    def initialize(node, edge)
      super(
        "Another edge already exists on #{ node.inspect } which is too " \
        "similar to #{ edge.inspect }")
    end
  end

  # Raised when setting properties on an object, and the given object is not a
  # hash, or is invalid in some way.
  class InvalidPropertiesError < TurbineError
    def initialize(model, properties)
      super(
        "Tried to assign properties #{ properties.inspect } on " \
        "#{ model.inspect } - it must be a Hash, or subclass of Hash")
    end
  end # InvalidPropertiesError

  # Raised when trying to topologically sort a graph which contains loops.
  class CyclicError < TurbineError
    def initialize(orig_exception)
      set_backtrace(orig_exception.backtrace)
      super(orig_exception.message)
    end
  end # CyclicError

  # Raised when trying to access values from a non-existant Journal segment.
  class NoSuchJournalError < TurbineError
    def initialize(name)
      super("No such upstream journal: #{ name.inspect }")
    end
  end # NoSuchJournalError

  # Raised when trying to get trace information from a pipeline when tracing
  # has not been enabled.
  class TracingNotEnabledError < TurbineError
    def initialize(segment)
      super(
        "You cannot get trace information from the #{ segment.inspect } " \
        "segment as tracing is not enabled")
    end
  end # TracingNotEnabledError

  # Raised when trying to enable tracing on a segment which doesn't support
  # it.
  class NotTraceableError < TurbineError
    def initialize(segment)
      super(
        "You cannot enable tracing on pipelines with " \
        "#{ segment.class.name } segments")
    end
  end # NotTraceableError
end # Turbine
