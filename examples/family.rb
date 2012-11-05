require 'turbine'

module Turbine

  # This example is taken from a TV show called 'Modern Family' with complex
  # family relations, in other words: ideal to test a complex graph structure.
  #
  # http://en.wikipedia.org/wiki/List_of_Modern_Family_characters
  def self.family_stub
    graph    = Turbine::Graph.new

    phil     = graph.add(Turbine::Node.new(:phil,     gender: :male))
    claire   = graph.add(Turbine::Node.new(:claire,   gender: :female))
    haley    = graph.add(Turbine::Node.new(:haley,    gender: :female))
    alex     = graph.add(Turbine::Node.new(:alex,     gender: :female))
    luke     = graph.add(Turbine::Node.new(:luke,     gender: :male))

    jay      = graph.add(Turbine::Node.new(:jay,      gender: :male))
    gloria   = graph.add(Turbine::Node.new(:gloria,   gender: :female))
    manny    = graph.add(Turbine::Node.new(:manny,    gender: :male))
    unnamed  = graph.add(Turbine::Node.new(:unnamed))

    mitchell = graph.add(Turbine::Node.new(:mitchell, gender: :male))
    cameron  = graph.add(Turbine::Node.new(:cameron,  gender: :male))
    lily     = graph.add(Turbine::Node.new(:lily,     gender: :female))

    dede     = graph.add(Turbine::Node.new(:dede,     gender: :female))
    javier   = graph.add(Turbine::Node.new(:javier,   gender: :male))

    frank    = graph.add(Turbine::Node.new(:frank,    gender: :male))
    sarah    = graph.add(Turbine::Node.new(:sarah,    gender: :female))

    # Dunphy -----------------------------------------------------------------

    # Phil
    phil.connect_to(claire,  :spouse)
    phil.connect_to(haley,   :child)
    phil.connect_to(alex,    :child)
    phil.connect_to(luke,    :child)

    # Claire
    claire.connect_to(phil,  :spouse)
    claire.connect_to(haley, :child)
    claire.connect_to(alex,  :child)
    claire.connect_to(luke,  :child)

    # Pritchett --------------------------------------------------------------

    # Jay
    jay.connect_to(gloria,     :spouse)
    jay.connect_to(claire,     :child)
    jay.connect_to(mitchell,   :child)
    jay.connect_to(unnamed,    :child)
    jay.connect_to(dede,       :divorced)

    # Gloria
    gloria.connect_to(jay,     :spouse)
    gloria.connect_to(manny,   :child)
    gloria.connect_to(unnamed, :child)
    gloria.connect_to(javier,  :divorced)

    # Tucker-Pritchett -------------------------------------------------------

    mitchell.connect_to(cameron, :spouse)
    mitchell.connect_to(lily,    :child)

    cameron.connect_to(mitchell, :spouse)
    cameron.connect_to(lily,     :child)

    # Others -----------------------------------------------------------------

    dede.connect_to(claire,   :child)
    dede.connect_to(mitchell, :child)

    javier.connect_to(manny, :child)

    frank.connect_to(phil,   :child)
    frank.connect_to(sarah,  :spouse)

    sarah.connect_to(phil,   :child)
    sarah.connect_to(frank,  :spouse)

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
