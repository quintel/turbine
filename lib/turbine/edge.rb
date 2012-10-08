module Turbine
  # Edges represent a connection between an +in+ vertex and an +out+ vertex.
  #
  # Note that simply creating an Edge does not actually establish the
  # connection between the two vertices. Rather than creating the Edge
  # instance manually, Vertex can do this for you with +Vertex#connect_to+ and
  # +Vertex#connect_via+:
  #
  #   jay    = Turbine::Vertex.new(:jay)
  #   gloria = Turbine::Vertex.new(:gloria)
  #
  #   jay.connect_to(gloria, :spouse)
  #   gloria.connect_to(jay, :spouse)
  #
  # However, if you want to do it manually (perhaps with a subclass of Edge),
  # you should use +Vertex#connect_via+:
  #
  #   jay    = Turbine::Vertex.new(:jay)
  #   gloria = Turbine::Vertex.new(:gloria)
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
    # Public: Returns the edge's in vertex.
    attr_reader :in

    # Public: Returns the edge's out vertex.
    attr_reader :out

    # Public: Returns the optional label assigned to the edge.
    attr_reader :label

    # Public: Creates a new Edge.
    #
    # in_vertex  - The Vertex which is connected to the +out+ vertex.
    # out_vertex - The Vertex which is being connected to by the +in+ vertex.
    # label      - An optional label for describing the nature of the
    #              relationship between the two vertices.
    #
    def initialize(in_vertex, out_vertex, label = nil)
      @in    = in_vertex
      @out   = out_vertex
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
