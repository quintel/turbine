# Turbine

An in-memory graph database written in Ruby to model an Energy Flow network.

The idea behind Turbine is to provide a common base library for the graph
structure used in ETengine, as well as defining better ways to traverse this
structure. As a "property graph", it should also handle the datasets which we
assign to Converters, Links, etc.

The aim is for Turbine to be used in ETsource as a means for "filtering" the
data which comes out of InputExcel (such as calculating demands, removing
slot "conversion" attributes for loss slots, etc), before traversing the
graph one final time to save the output to YAML.

In the future, ETengine Qernel classes may be descendants of those in Turbine
(e.g. Converter becomes a subclass of Turbine::Node; Link become subclasses on
Turbine::Edge [perhaps with further specialsed subclasses: ShareLink,
ConstantLink, etc]).

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
