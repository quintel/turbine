module Turbine
  # In graph theory, a node is the fundamental unit of which graphs are
  # formed: a directed graph consists of a set of nodes and a set of arcs
  # (ordered pairs of nodes).
  class Node
    include Properties

    # Public: Returns the unique key which identifies the node.
    attr_reader :key

    # Creates a new Node.
    def initialize(key)
      @key        = key
      @in_edges   = Set.new
      @out_edges  = Set.new
    end

    # Public: Returns nodes which have an outgoing edge to this node.
    #
    # label - An optional label by which to filter the in edges, before
    #         fetching the matched nodes.
    #
    # Returns an array of Node instances.
    def in(label = nil)
      in_edges(label).map(&:in)
    end

    # Public: Returns verticies to which this node has outgoing edges.
    #
    # label - An optional label by which to filter the out edges, before
    #         fetching the matched nodes.
    #
    # Returns an array of Node instances.
    def out(label = nil)
      out_edges(label).map(&:out)
    end

    # Public: Returns this node's in edges.
    #
    # label - An optional label; only edges with this label will be returned.
    #         Passing nil will return all in edges.
    #
    # Returns an array of Edges.
    def in_edges(label = nil)
      label.nil? ? @in_edges : @in_edges.select { |e| e.label == label }
    end

    # Public: Returns this node's out edges.
    #
    # label - An optional label; only edges with this label will be returned.
    #         Passing nil will return all out edges.
    #
    # Returns an array of Edges.
    def out_edges(label = nil)
      label.nil? ? @out_edges : @out_edges.select { |e| e.label == label }
    end

    # Public: Returns a human-readable version of the node.
    def inspect
      "#<Turbine::Node key=#{ @key.inspect }>"
    end

    # Public: Connects this node to another.
    #
    # target - The node to which you want to connect. The +target+ node
    #          will be the "out" end of the edge.
    # label  - An optional label describing the relationship between the two
    #          nodes.
    #
    # Example:
    #
    #   phil = Turbine::Node.new(:phil)
    #   luke = Turbine::Node.new(:luke)
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

    # Internal: Given an Edge, establishes the connection for this node.
    #
    # Please note that you need to call +connect_via+ on both the "in" and
    # "edge" nodes. Unless you need to create the connection using a
    # subclass of Edge, you will likey prefer using the simpler +connect_to+.
    #
    # Example:
    #
    #   phil  = Turbine::Node.new(:phil)
    #   haley = Turbine::Node.new(:haley)
    #
    #   edge  = Turbine::Edge.new(phil, haley, :child)
    #
    #   # Adds an +out+ link from "phil" to "haley".
    #   phil.connect_via(edge)
    #   haley.connect_via(edge)
    #
    # Raises a Turbine::CannotConnectError if this node is not the +in+ or
    # +out+ node specified by the edge.
    #
    # Returns the given edge.
    def connect_via(edge)
      @in_edges.add(edge)  if edge.out == self
      @out_edges.add(edge) if edge.in  == self

      edge
    end

  end # Node
end # Turbine
