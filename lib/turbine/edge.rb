module Turbine
  # Edges represent a connection between an +from+ node and an +to+ node.
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

    # Public: The node which the edge leaves; the edge is an +out_edge+ on
    # this node.
    attr_reader :from

    # Public: The node to which the edge points; the edge is an +in_edge+ on
    # this node.
    attr_reader :to

    # Public: Returns the optional label assigned to the edge.
    attr_reader :label

    # Attribute aliases.
    alias_method :parent, :from
    alias_method :child,  :to

    # Public: Creates a new Edge.
    #
    # from_node  - The Node from which the edge originates.
    # to_node    - The Node to which the edge points.
    # label      - An optional label for describing the nature of the
    #              relationship between the two nodes.
    # properties - Optional key/value properties to be associated with the
    #              edge.
    #
    def initialize(from_node, to_node, label = nil, properties = nil)
      @from  = from_node
      @to    = to_node
      @label = label

      self.properties = properties
    end

    # Public: Determines if the +other+ edge is similar to this one.
    #
    # Two edges are considered similar if have the same +to+ and +from+ nodes,
    # and their label is identical.
    #
    # Returns true or false.
    def similar?(other)
      other && other.to == @to && other.from == @from && other.label == @label
    end

    # Public: Returns a human-readable version of the edge.
    def inspect
      "#<#{ self.class.name } #{ to_s }>".sub('>', "\u27A4")
    end

    # Public: Returns a human-readable version of the edge by showing the from
    # and to nodes, connected by the label.
    def to_s
      "#{ @from.key.inspect } -#{ @label.inspect }-> #{ @to.key.inspect }"
    end

    # Internal: A low-level method which retrieves the node in a given
    # direction. Used for compatibility with Pipeline.
    #
    # Returns a Node.
    def nodes(direction, *)
      direction == :to ? @to : @from
    end
  end # Edge
end # Turbine
