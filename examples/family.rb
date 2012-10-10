require 'turbine'

module Turbine
  def self.stub
    graph    = Turbine::Graph.new

    phil     = graph.add_node(Turbine::Node.new(:phil))
    claire   = graph.add_node(Turbine::Node.new(:claire))
    haley    = graph.add_node(Turbine::Node.new(:haley))
    alex     = graph.add_node(Turbine::Node.new(:alex))
    luke     = graph.add_node(Turbine::Node.new(:luke))

    jay      = graph.add_node(Turbine::Node.new(:jay))
    gloria   = graph.add_node(Turbine::Node.new(:gloria))
    manny    = graph.add_node(Turbine::Node.new(:manny))
    unnamed  = graph.add_node(Turbine::Node.new(:unnamed))

    mitchell = graph.add_node(Turbine::Node.new(:mitchell))
    cameron  = graph.add_node(Turbine::Node.new(:cameron))
    lily     = graph.add_node(Turbine::Node.new(:lily))

    dede     = graph.add_node(Turbine::Node.new(:dede))
    javier   = graph.add_node(Turbine::Node.new(:javier))

    frank    = graph.add_node(Turbine::Node.new(:frank))
    sarah    = graph.add_node(Turbine::Node.new(:sarah))

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

    # Pritchett --------------------------------------------------------------

    # Jay
    jay.connect_to(gloria, :spouse)
    jay.connect_to(claire, :child)
    jay.connect_to(mitchell, :child)
    jay.connect_to(unnamed, :child)
    jay.connect_to(dede, :divorced)

    # Gloria
    gloria.connect_to(jay, :spouse)
    gloria.connect_to(manny, :child)
    gloria.connect_to(unnamed, :child)
    gloria.connect_to(javier, :divorced)

    # Tucker-Pritchett -------------------------------------------------------

    mitchell.connect_to(cameron, :spouse)
    mitchell.connect_to(lily, :child)

    cameron.connect_to(mitchell, :spouse)
    cameron.connect_to(lily, :child)

    # Others -----------------------------------------------------------------

    dede.connect_to(claire, :child)
    dede.connect_to(mitchell, :child)

    javier.connect_to(manny, :child)

    frank.connect_to(phil, :child)
    frank.connect_to(sarah, :spouse)

    sarah.connect_to(phil, :child)
    sarah.connect_to(frank, :spouse)

    graph
  end
end

# Find out that Manny is Jay's step-child with:
#
#   jay = Turbine.stub.node(:jay)
#   jay.out(:spouse).out(:child) - jay.out(:child)
#
#   # => #<Turbine::Collection {#<Turbine::Node key=:manny>}>
#
# ... or that Alex has two siblings:
#
#   alex = Turbine.stub.node(:alex)
#   alex.in(:child).out(:child) - [alex]
#
# ... or that Jay and Gloria have a single "common" child:
#
#   graph = Turbine.stub
#   jay, gloria = graph.node(:jay), graph.node(:gloria)
#
#   jay.out(:child) & gloria.out(:child)
#
#   # => #<Turbine::Collection {#<Turbine::Node key=:unnamed>}>
#
# ... or who are Luke's uncles and aunts:
#
#   graph = Turbine.stub
#   luke  = graph.node(:luke)
#
#   parents      = luke.in(:child)
#   grandparents = parents.in(:child)
#
#   # Remove Claire, Luke's mother:
#   uncles_and_aunts = grandparents.out(:child) - parents
#
#   # And add the uncle and aunt spouses for the full list.
#   uncles_and_aunts + uncles_and_aunts.out(:spouse)
#
#   # => #<Turbine::Collection {
#          #<Turbine::Node key=:mitchell>,
#          #<Turbine::Node key=:unnamed>,
#          #<Turbine::Node key=:cameron>}>
