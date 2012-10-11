# Turbine

An in-memory graph database written in Ruby to model an Energy Flow network.

## Example

We start the console and load the example graph

    $> rake console:stub

We build the example graph

    pry> graph = Turbine.stub
    => #<Turbine::Graph (16 nodes, 28 edges)>

We can search for a node:

    pry> graph.node(:claire)
    => #<Turbine::Node key=:claire>

Traverse the graph by asking what are the **outward** connections

    pry> graph.node(:claire).out.size
    => 4

Traverse the graph by asking what are the **inward** connections

    pry> graph.node(:claire).in
    => 3

You can also chain this:

    pry> graph.node(:clair).in.in.size
    => 5

## Idea

The idea behind Turbine is to provide a common base library for the graph
structure used in ETengine, as well as defining ways to traverse this
structure. As a "property graph".

Turbine also handles the datasets which we assign to Converters, Links, etc.

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

    Today
    -----

    CSV  ->  xls2yml  ->  *simple dataset modifications*  ->  YAML

    With turbine
    ------------

    CSV  ->  Turbine graph in ETsource  ->  *dataset modifications*  ->  YAML

    In the future
    -------------

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

In graph theory, nodes and edges are used simultanously. Since we prefer
shorter words over longer: we use *Node*.

### Directed Graph

Turbine is a directed graph, which means that the connection between two
*nodes* have a direction: it either goes from A to B or reversed.

## Start!

If you want to fool around with Turbine, fire up your console

    $> rake console

First you need to create a new (at least one...) `Graph`:

    graph = Turbine::Graph.new
    => #<Turbine::Graph (0 nodes)>

You can add Nodes to it:
