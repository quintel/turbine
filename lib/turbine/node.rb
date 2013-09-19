module Turbine
  # In graph theory, a node is the fundamental unit of which graphs are
  # formed: a directed graph consists of a set of nodes and a set of edges.
  class Node
    include Properties

    # Public: Returns the unique key which identifies the node.
    attr_reader :key

    # Creates a new Node.
    #
    # key        - A unique identifier for the node. The uniqueness of the key
    #              is not checked upon initializing, but instead when the node
    #              is added to the graph (Graph#add).
    # properties - Optional key/value properties to be associated with the
    #              node.
    #
    # Returns the node.
    def initialize(key, properties = nil)
      @key        = key
      @in_edges   = Set.new
      @out_edges  = Set.new

      self.properties = properties
    end

    # Public: Returns nodes which have an outgoing edge to this node.
    #
    # label - An optional label by which to filter the in edges, before
    #         fetching the matched nodes.
    #
    # Returns an array of Node instances.
    def in(label = nil)
      Pipeline.dsl(self).in(label)
    end

    # Public: Returns verticies to which this node has outgoing edges.
    #
    # label - An optional label by which to filter the out edges, before
    #         fetching the matched nodes.
    #
    # Returns an array of Node instances.
    def out(label = nil)
      Pipeline.dsl(self).out(label)
    end

    # Public: Returns this node's incoming edges.
    #
    # label - An optional label; only edges with this label will be returned.
    #         Passing nil will return all in edges.
    #
    # Raises an InvalidEdgeFilterError if you supply both a +label+ and
    # +block+ for filtering the edges.
    #
    # Returns an array of Edges.
    def in_edges(label = nil)
      Pipeline.dsl(self).in_edges(label)
    end

    # Public: Returns this node's outgoing edges.
    #
    # label - An optional label; only edges with this label will be returned.
    #         Passing nil will return all out edges.
    #
    # Raises an InvalidEdgeFilterError if you supply both a +label+ and
    # +block+ for filtering the edges.
    #
    # Returns an array of Edges.
    def out_edges(label = nil)
      Pipeline.dsl(self).out_edges(label)
    end

    # Public: Returns an enumerator containing all nodes which are outward
    # nodes, and all of their outward nodes.
    #
    # Uses a BreadthFirst traversal so that immediately adjacent nodes are
    # visited before more distant nodes.
    #
    # Returns an Enumerator containing Nodes.
    def descendants(label = nil)
      Pipeline.dsl(self).descendants(label)
    end

    # Public: Returns an enumerator containing all nodes which are inward
    # nodes, and all of their inward nodes.
    #
    # Uses a BreadthFirst traversal so that immediately adjacent nodes are
    # visited before more distant nodes.
    #
    # Returns an Enumerator containing Nodes.
    def ancestors(label = nil)
      Pipeline.dsl(self).ancestors(label)
    end

    # Internal: Low-level method which retrieves all of the edges in a given
    # +direction+, in an array.
    #
    # Returns an array of edges.
    def edges(direction, label = nil)
      select_edges(direction == :in ? @in_edges : @out_edges, label)
    end

    # Internal: Low-level method which retrieves all of the nodes in a given
    # +direction+, in an array.
    #
    # Returns an array of nodes.
    def nodes(direction, label = nil)
      edges(direction, label).map(&(direction == :in ? :from : :to))
    end

    # Public: Returns a human-readable version of the node.
    def inspect
      "#<#{ self.class.name } key=#{ @key.inspect }>"
    end

    alias_method :to_s, :inspect

    # Public: Connects this node to another.
    #
    # target     - The node to which you want to connect. The +target+ node
    #              will be the "from" end of the edge.
    # label      - An optional label describing the relationship between the
    #              two nodes.
    # properties - Optional key/value properties to be associated with the
    #              edge.
    #
    # Example:
    #
    #   phil = Turbine::Node.new(:phil)
    #   luke = Turbine::Node.new(:luke)
    #
    #   phil.connect_to(luke, :child)
    #
    # Returns the Edge which was created.
    #
    # Raises a Turbine::DuplicateEdgeError if the Edge already existed.
    def connect_to(target, label = nil, properties = nil)
      Edge.new(self, target, label, properties).tap do |edge|
        self.connect_via(edge)
        target.connect_via(edge)
      end
    end

    # Public: Disconnects this node from the +target+. Assumes that the
    # receiver is the +from+ node.
    #
    # target - The node from which the receiver is to be disconnected.
    # label  - An optional label; only the edge with this label will be
    #          removed, with other edges kept intact. No label will remove all
    #          outward edges between the receiver and the target.
    #
    # Raises NoSuchEdge if the two nodes are not connected.
    #
    # Returns nothing.
    def disconnect_from(target, label = nil)
      edges(:out, label).select { |edge| edge.to == target }.each do |edge|
        disconnect_via(edge)
        target.disconnect_via(edge)
      end

      nil
    end

    # Internal: Given an Edge, establishes the connection for this node.
    #
    # Please note that you need to call +connect_via+ on both the "from" and
    # "to" nodes. Unless you need to create the connection using a subclass of
    # Edge, you will likey prefer using the simpler +connect_to+.
    #
    # Example:
    #
    #   phil  = Turbine::Node.new(:phil)
    #   haley = Turbine::Node.new(:haley)
    #
    #   edge  = Turbine::Edge.new(phil, haley, :child)
    #
    #   # Adds an link from "phil" to "haley".
    #   phil.connect_via(edge)
    #   haley.connect_via(edge)
    #
    # Raises a Turbine::CannotConnectError if this node is not the +from+ or
    # +to+ node specified by the edge.
    #
    # Returns the given edge.
    def connect_via(edge)
      connect_endpoint(@in_edges, edge)  if edge.to   == self
      connect_endpoint(@out_edges, edge) if edge.from == self

      edge
    end

    # Internal: Given an edge, removes the connection for this node.
    #
    # Please note that you need to call +disconnect_via+ on both the "from"
    # and "to" nodes.
    #
    # Example:
    #
    #   haley = Turbine::Node.new(:haley)
    #   dylan = Turbine::Node.new(:dylan)
    #
    #   edge  = haley.connect_to(dylan, :boyfriend)
    #
    #   haley.disconnect_via(edge)
    #   dylan.disconnect_via(edge)
    #
    # Returns nothing.
    def disconnect_via(edge)
      @in_edges.delete(edge)
      @out_edges.delete(edge)

      nil
    end

    #######
    private
    #######

    # Internal: Given an edge, and a Node's in_edges or out_edges, adds the
    # edge only if there is not a similar edge already present.
    #
    # collection - The collection to which the edge is to be added.
    # edge       - The edge.
    #
    # Returns nothing.
    def connect_endpoint(collection, edge)
      if collection.any? { |o| ! edge.equal?(o) && edge.similar?(o) }
        raise DuplicateEdgeError.new(self, edge)
      end

      collection.add(edge)
    end

    # Internal: Given an array of edges, and an optional label label, selects
    # the edges from the given set.
    #
    # edges - The array of edges to be filtered.
    # label - The label of the edges to be emitted.
    #
    # Returns an array of edges.
    def select_edges(edges, label)
      label.nil? ? edges : edges.select { |edge| edge.label == label }
    end

  end # Node
end # Turbine
