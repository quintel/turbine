# Turbine

An in-memory graph database written in Ruby to model an Energy Flow network.

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
