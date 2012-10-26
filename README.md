# Turbine [![Build Status](https://secure.travis-ci.org/quintel/turbine.png)](http://travis-ci.org/quintel/turbine)

An in-memory directed graph written in Ruby to model an energy flow system,
a family tree, or whatever you like!

## Quick tour

We start the console with `rake console:stub` and load the example graph:

```ruby
graph = Turbine.energy_stub
# => #<Turbine::Graph (16 nodes, 16 edges)>
```

### Searching

Now you can search for a node:

```ruby
graph.node(:space_heater_chp)
# => #<Turbine::Node key=:space_heater_chp>
```

It will return nil when the collection is empty, or if no node with the given
key exists:

```ruby
graph.node(:bob_ross)
# => nil
```

### Traversing the graph

Please see the [Terminology](#terminology) section if you are confused by the
use of **in** and **out**.

#### Adjacent nodes

Traverse the graph by requesting the inward nodes of a node:

```ruby
graph.node(:space_heater_chp).in.to_a
# => [#<Turbine::Node>, #<Turbine::Node>, ...]
```

Traverse the graph by requesting the outward nodes:

```ruby
graph.node(:space_heater_chp).out.to_a
# => [#<Turbine::Node>, #<Turbine::Node>, ...]
```

#### Filtering nodes

If you have a node and you want to get all the inward or outward nodes that
have a certain label, you can use a filter:

```ruby
graph.node(:space_heater_chp).out(:electricity).to_a
# => [#<Turbine::Node key=:useful_demand_elec>]

graph.node(:space_heater_chp).out(:heat).to_a
# => [<Turbine::Node key=:useful_demand_heat>}>]
```

#### Traversing edges

You can do the same for edges with `in_edges` and `out_edges`:

```ruby
graph.node(:space_heater_chp).in_edges.to_a
# => [ #<Turbine::Edge :space_heater_coal -:heat-> :useful_demand_heat>,
#      #<Turbine::Edge :space_heater_gas -:heat-> :useful_demand_heat>,
#      #<Turbine::Edge :space_heater_oil -:heat-> :useful_demand_heat>,
#      #<Turbine::Edge :space_heater_chp -:heat-> :useful_demand_heat> ]
```

#### Chaining

You can also chain and step through the connections:

```ruby
node = graph.nodes.first
node.in.in.to_a
# => [ #<Turbine::Node key=:final_demand_coal>,
#      #<Turbine::Node key=:final_demand_gas>,
#      #<Turbine::Node key=:final_demand_oil> ]
```

#### Ancestors and Descendants

Alternatively, you can recursively fetch all ancestors or descendants of a
Node:

```ruby
enum = node.ancestors.to_a
# => [#<Turbine::Node>, #<Turbine::Node>, ...]
```

Just like with `in` and `out`, you may opt to filter the traversed nodes by
the label of the connecting edge:

```ruby
enum = node.descendants(:likes)
# => #<Enumerator: ...>
```

Ancestors and descendants are fetched using a breadth-first algorithm, but
depth-first is also available:

```ruby
enum = Turbine::Traversal::DepthFirst(node, :in).to_enum
# => #<Enumerator: ...>
```

Each adjacent node is visited no more than once during the traversal, i.e.
loops are not followed.

### Properties / Attributes

You can set all kind of properties on a node:

```ruby
node = graph.nodes.first
node.properties
# => {} # no properties set!

node.get(:preset_demand)
# => nil # no property called :preset_demand set!

node.set(:preset_demand, 1_000)
# => 1000

node.properties
# => {:preset_demand=>1000}
```

## Terminology

#### Node

In graph theory, the term **Node** and **Vertex** are used interchangeably.
Since we prefer shorter words over longer: we use node.

#### Edges

An **edge** (or sometimes called an **arc**) is a connection between two
nodes.

#### Directed graph

Turbine is a directed graph, which means that the connection between two
nodes always has a direction: it either goes from A to B or the other way
round.

#### In and out

When Node A is connected to Node B:

    A --> B

A is said to be the **ancestor** of B, and B is called the **descendant** of
A. Since we like to keep things as short as possible, we choose **in** and
**out**: `A.out` results in `B`, and `B.in` results in `A`.

Hence, we have the following truth table:

         |  in | out
    -----+-----+------
      A  | nil |  B
    -----+-----+------
      B  |  A  | nil

Still, it is up to the user to define what the direction signifies: in the
case of an energy graph: the energy flows from a coal plant to the electricity
grid. (some might argue that the demand flows from the grid to the power
plant).

In the case of the family graph, it is the ancestry of people:

    parent -:child-> child

If the relation is equal, there are two edges defined and a symmetrical
relationship exists (Turbine does not support bi-directional edges):

    person1 -:spouse-> person2
    person2 -:spouse-> person1

    i.e., person1 <-> person2
