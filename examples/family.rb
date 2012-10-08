module Turbine
  def self.stub
    graph    = Turbine::Graph.new

    phil     = graph.add_vertex(Turbine::Vertex.new(:phil))
    claire   = graph.add_vertex(Turbine::Vertex.new(:claire))
    haley    = graph.add_vertex(Turbine::Vertex.new(:haley))
    alex     = graph.add_vertex(Turbine::Vertex.new(:alex))
    luke     = graph.add_vertex(Turbine::Vertex.new(:luke))

    jay      = graph.add_vertex(Turbine::Vertex.new(:jay))
    gloria   = graph.add_vertex(Turbine::Vertex.new(:gloria))
    manny    = graph.add_vertex(Turbine::Vertex.new(:manny))

    mitchell = graph.add_vertex(Turbine::Vertex.new(:mitchell))
    cameron  = graph.add_vertex(Turbine::Vertex.new(:cameron))
    lily     = graph.add_vertex(Turbine::Vertex.new(:lily))

    # Dunphy -----------------------------------------------------------------

    # Phil
    phil.connect_to(claire, :spouse)
    phil.connect_to(haley, :child)
    phil.connect_to(alex, :child)
    phil.connect_to(luke, :child)

    # Claire
    claire.connect_to(phil, :spouse)
    claire.connect_to(haley, :child)
    claire.connect_to(alex, :child)
    claire.connect_to(luke, :child)
    claire.connect_to(jay, :parent)

    # Haley
    haley.connect_to(phil, :parent)
    haley.connect_to(claire, :parent)
    haley.connect_to(alex, :sibling)
    haley.connect_to(luke, :sibling)

    # Alex
    alex.connect_to(phil, :parent)
    alex.connect_to(claire, :parent)
    alex.connect_to(haley, :sibling)
    alex.connect_to(luke, :sibling)

    # Luke
    luke.connect_to(phil, :parent)
    luke.connect_to(claire, :parent)
    luke.connect_to(haley, :sibling)
    luke.connect_to(alex, :sibling)

    # Pritchett --------------------------------------------------------------

    # Jay
    jay.connect_to(gloria, :spouse)
    jay.connect_to(claire, :child)
    jay.connect_to(mitchell, :child)
    jay.connect_to(manny, :step_child)

    # Gloria
    gloria.connect_to(jay, :spouse)
    gloria.connect_to(manny, :child)

    # Manny
    manny.connect_to(gloria, :parent)
    manny.connect_to(jay, :step_parent)

    # Tucker-Pritchett -------------------------------------------------------

    mitchell.connect_to(jay,  :parent)
    mitchell.connect_to(cameron, :spouse)
    mitchell.connect_to(claire, :sibling)
    mitchell.connect_to(lily, :child)

    cameron.connect_to(mitchell, :spouse)
    cameron.connect_to(lily, :child)

    graph
  end
end
