module Turbine
  # Error class which serves as a base for all errors which occur in Turbine.
  TurbineError = Class.new(StandardError)

  # Internal: Creates a new error class which inherits from TurbineError,
  # whose message is created by evaluating the block you give.
  #
  # For example
  #
  #   MyError = error_class do |weight, limit|
  #     "#{ weight } exceeds #{ limit }"
  #   end
  #
  #   raise MyError.new(5000, 2500)
  #   # => #<Turbine::MyError: 5000 exceeds 2500>
  #
  # Returns an exception class.
  def self.error_class(superclass = TurbineError, &block)
    Class.new(superclass) do
      def initialize(*args) ; super(make_message(*args)) ; end
      define_method(:make_message, &block)
    end
  end

  # Added a node to a graph, when one already exists with the same key.
  DuplicateNodeError = error_class do |key|
    "Graph already has a node with the key #{ key.inspect }"
  end

  # Added an edge between two nodes which was too similar to an existing edge.
  # See Edge#similar?
  DuplicateEdgeError = error_class do |node, edge|
    "Another edge already exists on #{ node.inspect } which is too similar " \
    "to #{ edge.inspect }"
  end

  # Attempted to set properties on an object, when the properties were not in
  # the form of a hash, or were otherwise invalid in some way.
  InvalidPropertiesError = error_class do |model, properties|
    "Tried to assign properties #{ properties.inspect } on " \
    "#{ model.inspect } - it must be a Hash, or subclass of Hash"
  end

  # Tried to access values from a non-existant Journal segment.
  NoSuchJournalError = error_class do |name|
    "No such upstream journal: #{ name.inspect }"
  end

  # Attempted to get trace information from a pipeline when tracing has not
  # been enabled.
  TracingNotEnabledError = error_class do |segment|
    "You cannot get trace information from the #{ segment.inspect } " \
    "segment as tracing is not enabled"
  end

  # Tried to enable tracing on a segment which doesn't support it.
  NotTraceableError = error_class do |segment|
    "You cannot enable tracing on pipelines with #{ segment.class.name } " \
    "segments"
  end

  # Tried to topologically sort a graph which contains loops.
  class CyclicError < TurbineError
    def initialize(orig_exception)
      set_backtrace(orig_exception.backtrace)
      super(orig_exception.message)
    end
  end
end # Turbine
