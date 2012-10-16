# Turbine

An in-memory directed graph written in Ruby to model an energy flow system,
a family tree, or whatever you like!

## Check it out!

We start the console and load the example graph

    $> rake console:stub

Load an example graph

    pry> graph = Turbine.energy_stub
    => #<Turbine::Graph (16 nodes, 16 edges)>

### Searching

Now you can search for a node:

    pry> graph.node(:space_heater_chp)
    => #<Turbine::Node key=:space_heater_chp>

It will return nil when the collection is empty:

    pry> graph.node(:bob_ross)
    => nil

### Traversing the graph

Traverse the graph by requesting the **inward** connections of a node

    pry> graph.node(:space_heater_chp).in
    => #<Turbine::Collection {#<Turbine::Node key=:final_demand_gas>}>

Traverse the graph by requesting the **outward** connections

    pry> g.node(:space_heater_chp).out
    => #<Turbine::Collection {#<Turbine::Node key=:useful_demand_heat>,
                              #<Turbine::Node key=:useful_demand_elec>}>

### Chaining

You can also **chain** and **step** through the connections:

    pry> a_node = graph.nodes.first
    pry> a_node.in.in # and we moved two steps to the 'right'
    => #<Turbine::Collection {#<Turbine::Node key=:final_demand_coal>,
                              #<Turbine::Node key=:final_demand_gas>,
                              #<Turbine::Node key=:final_demand_oil>}>

### Properties/Attributes

You can set all kind of *properties* (or call them *attributes* as you wish)
on a node:

    pry> a_node = graph.nodes.first
    pry> a_node.properties
    => {} # no properties set!
    pry> a_node.properties[:preset_demand]
    => nil # no property preset_demand set!
    pry> a_node.properties[:preset_demand] = 1_000
    => 1000
    pry> a_node.properties
    => {:preset_demand=>1000}

## Idea

The idea behind Turbine is to provide a common base library for the graph
structure used in ETengine, as well as defining ways to traverse this
structure.

As a "property graph", Turbine also handles the datasets which we assign to
Nodes (or Converters), Edges (or Links), etc.

## Roadmap

The aim is for a Turbine graph to be built using the InputExcel CSV data, and
for this graph to then be modified in-memory:

  * Perform demand calculations,
  * Remove conversions for loss output slots,
  * Transform carrier-efficiency data so it can be used by ETengine,
  * etc ...

Then, the modified graph will be "dumped" to YAML for use by ETengine. In the
short-term, this means we can have a full graph structure up-and-running in
ETsource to which we can slowly migrate features from InputExcel. If we
remove InputExcel in the future, we simply replace the CSV input with
_something else_. Or, perhaps the Turbine graph will itself become the base
for the InputExcel replacement?

#### Today

    CSV  ->  xls2yml  ->  *simple dataset modifications*  ->  YAML

#### With turbine

    CSV  ->  Turbine graph in ETsource  ->  *dataset modifications*  ->  YAML

#### In the future

    ???  ->  Turbine graph in ETsource  ->  *dataset modifications*  ->  YAML

    or:

    Flat files  ->  Turbine graph  ->  YAML

    or:

    Ruby DSL  -> Turbine graph  ->  YAML

    or:

    ???

Also in the longer-term, ETengine Qernel classes may be descendants of those
in Turbine (e.g. Converter becomes a subclass of Turbine::Node; Link become
subclasses on Turbine::Edge [perhaps with further specialsed subclasses:

## Jargon

### Node

In graph theory, *nodes* and *vertices* are used simultanously. Since we prefer
shorter words over longer: we use *Node*.

### Directed Graph

Turbine is a directed graph, which means that the connection between two
*nodes* has a direction: it either goes from A to B or the other way round.

### In and Out

When Node A is connected to Node B:

    A ---> B

`A.out` results in `B`, and `B.in` results in `A`.

We have the following *truth table*:

        |  in | out
   -----+-----+------
     A  | nil |  B
   -----+-----+------
     B  |  A  | nil
