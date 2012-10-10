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
    # Public: Returns the edge's in node.
    attr_reader :in

    # Public: Returns the edge's out node.
    attr_reader :out

    # Public: Returns the optional label assigned to the edge.
    attr_reader :label

    # Public: Creates a new Edge.
    #
    # in_node  - The Node which is connected to the +out+ node.
    # out_node - The Node which is being connected to by the +in+ node.
    # label      - An optional label for describing the nature of the
    #              relationship between the two nodes.
    #
    def initialize(in_node, out_node, label = nil)
      @in    = in_node
      @out   = out_node
      @label = label
    end

    # Public: Returns a human-readable version of the edge.
    def inspect
      "#<Turbine::Edge " \
        "#{ @in.key.inspect } --> #{ @out.key.inspect } " \
        "label=#{ @label.inspect }>"
    end
  end # Edge
end # Turbine
