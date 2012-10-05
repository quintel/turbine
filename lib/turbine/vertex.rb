module Turbine
  # In graph theory, a vertex is the fundamental unit of which graphs are
  # formed: a directed graph consists of a set of vertices and a set of arcs
  # (ordered pairs of vertices).
  class Vertex
    # Public: Returns the unique key which identifies the vertex.
    attr_reader :key

    # Public: Returns edges which connect other vertices to this one.
    attr_reader :in_edges

    # Public: Returns edges which connect this vertex to others.
    attr_reader :out_edges

    # Creates a new Vertex.
    def initialize(key)
      @key       = key
      @in_edges  = []
      @out_edges = []
    end

    # Public: Returns vertices which have an outgoing edge to this vertex.
    def in
      @in_edges.map(&:in)
    end

    # Public: Returns verticies to which this vertex has outgoing edges.
    def out
      @out_edges.map(&:out)
    end

    # Public: Returns a human-readable version of the vertex.
    def inspect
      "#<Turbine::Vertex key=#{ @key.inspect }>"
    end
  end # Vertex
end # Turbine
