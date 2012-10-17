module Turbine
  # Edges represent a connection between an +in+ node and an +out+ node.
  #
  # Note that simply creating an Edge does not actually establish the
  # connection between the two nodes. Rather than creating the Edge
  # instance manually, Node can do this for you with +Node#connect_to+ and
  # +Node#connect_via+:
  #
  #   jay    = Turbine::Node.new(:jay)
  #   gloria = Turbine::Node.new(:gloria)
  #
  #   jay.connect_to(gloria, :spouse)
  #   gloria.connect_to(jay, :spouse)
  #
  # However, if you want to do it manually (perhaps with a subclass of Edge),
  # you should use +Node#connect_via+:
  #
  #   jay    = Turbine::Node.new(:jay)
  #   gloria = Turbine::Node.new(:gloria)
  #
  #   jay_married_to_gloria = Turbine::Edge.new(jay, gloria, :spouse)
  #   gloria_married_to_jay = Turbine::Edge.new(gloria, jay, :spouse)
  #
  #   jay.connect_via(jay_married_to_gloria)
  #   gloria.connect_via(jay_married_to_gloria)
  #
  #   jay.connect_via(gloria_married_to_jay)
  #   gloria.connect_via(gloria_married_to_jay)
  #
  class Edge
    include Properties

    # Public: Returns the node for which this edge is the +out+ edge. This is
    # the node the edge leaves.
    attr_reader :out

    # Public: Returns the node for which this edge is the +in+ edge. This is
    # the node the edge points to.
    attr_reader :in

    # Public: Returns the optional label assigned to the edge.
    attr_reader :label

    # Public: Creates a new Edge.
    #
    # out_node   - The Node from which the edge originates.
    # in_node    - The Node to which the edge points.
    # label      - An optional label for describing the nature of the
    #              relationship between the two nodes.
    # properties - Optional key/value properties to be associated with the
    #              edge.
    #
    def initialize(out_node, in_node, label = nil, properties = nil)
      @out   = out_node
      @in    = in_node
      @label = label

      self.properties = properties
    end

    # Public: Determines if the +other+ edge is similar to this one.
    #
    # Two edges are considered similar if have the same +in+ and +out+ nodes,
    # and their label is identical.
    #
    # Returns true or false.
    def similar?(other)
      other && other.in == @in && other.out == @out && other.label == @label
    end

    # Public: Returns a human-readable version of the edge.
    def inspect
      "#<#{ self.class.name } " \
        "#{ @out.key.inspect } -#{ @label.inspect }-> #{ @in.key.inspect }>"
    end
  end # Edge
end # Turbine
