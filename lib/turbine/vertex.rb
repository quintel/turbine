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
      @in_edges  = Set.new
      @out_edges = Set.new
    end

    # Public: Returns vertices which have an outgoing edge to this vertex.
    def in(label = nil)
      if label
        @in_edges.select { |edge| edge.label == label }.map(&:in)
      else
        @in_edges.map(&:in)
      end
    end

    # Public: Returns verticies to which this vertex has outgoing edges.
    def out(label = nil)
      if label
        @out_edges.select { |edge| edge.label == label }.map(&:out)
      else
        @out_edges.map(&:out)
      end
    end

    # Public: Returns a human-readable version of the vertex.
    def inspect
      "#<Turbine::Vertex key=#{ @key.inspect }>"
    end

    # Public: Connects this vertex to another.
    #
    # target - The vertex to which you want to connect. The +target+ vertex
    #          will be the "out" end of the edge.
    # label  - An optional label describing the relationship between the two
    #          vertices.
    #
    # Example:
    #
    #   phil = Turbine::Vertex.new(:phil)
    #   luke = Turbine::Vertex.new(:luke)
    #
    #   phil.connect_to(luke, :child)
    #
    # Returns the Edge which was created.
    def connect_to(target, label = nil)
      Edge.new(self, target, label).tap do |edge|
        self.connect_via(edge)
        target.connect_via(edge)
      end
    end

    # Internal: Given an Edge, establishes the connection for this vertex.
    #
    # Please note that you need to call +connect_via+ on both the "in" and
    # "edge" vertices. Unless you need to create the connection using a
    # subclass of Edge, you will likey prefer using the simpler +connect_to+.
    #
    # Example:
    #
    #   phil  = Turbine::Vertex.new(:phil)
    #   haley = Turbine::Vertex.new(:haley)
    #
    #   edge  = Turbine::Edge.new(phil, haley, :child)
    #
    #   # Adds an +out+ link from "phil" to "haley".
    #   phil.connect_via(edge)
    #   haley.connect_via(edge)
    #
    # Raises a Turbine::CannotConnectError if this vertex is not the +in+ or
    # +out+ vertex specified by the edge.
    #
    # Returns the given edge.
    def connect_via(edge)
      @in_edges.add(edge)  if edge.out == self
      @out_edges.add(edge) if edge.in  == self

      edge
    end

  end # Vertex
end # Turbine
