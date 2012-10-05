module Turbine
  # Edges represent a connection between an +in+ vertex and an +out+ vertex.
  class Edge
    # Public: Returns the edge's in vertex.
    attr_reader :in

    # Public: Returns the edge's out vertex.
    attr_reader :out

    # Public: Creates a new Edge.
    #
    # in_vertex  - The Vertex which is connected to the +out+ vertex.
    # out_vertex - The Vertex which is being connected to by the +in+ vertex.
    #
    def initialize(in_vertex, out_vertex)
      @in  = in_vertex
      @out = out_vertex
    end

    # Public: Returns a human-readable version of the edge.
    def inspect
      "#<Turbine::Edge in=#{ @in.key.inspect } out=#{ @out.key.inspect }>"
    end
  end # Edge
end # Turbine
