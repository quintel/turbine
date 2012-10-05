module Turbine
  # Contains vertices and edges.
  class Graph

    # Public: Creates a new graph.
    def initialize
      @vertices = {}
    end

    # Public: Adds the +vertex+ to the graph.
    #
    # vertex - The vertex to be added.
    #
    # Raises a DuplicateVertex is the graph already contains a vertex with the
    # same key.
    #
    # Returns the vertex.
    def add_vertex(vertex)
      if @vertices.key?(vertex.key)
        raise DuplicateVertex.new(vertex.key)
      end

      @vertices[vertex.key] = vertex
    end

    # Public: Retrieves the vertex whose key is +key+.
    #
    # key - The key of the desired vertex.
    #
    # Returns the vertex, or nil if no such vertex is known.
    def vertex(key)
      @vertices[key]
    end

    # Public: All of the vertices in an array.
    #
    # Generally speaking, the vertices will be returned in the same order as
    # they were added to the graph, however this may very depending on your
    # Ruby implementation.
    #
    # Returns an array of vertices.
    def vertices
      @vertices.values
    end

    # Public: A human-readable version of the graph.
    def inspect
      "#<Turbine::Graph (#{ @vertices.length } vertices)>"
    end

  end # Graph
end # Turbine
