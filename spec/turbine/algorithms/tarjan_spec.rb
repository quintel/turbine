require 'spec_helper'

module Turbine
  describe Algorithms::Tarjan do
    let(:graph) { Turbine::Graph.new }

    let(:a) { graph.add_node(Turbine::Node.new(:a)) }
    let(:b) { graph.add_node(Turbine::Node.new(:b)) }
    let(:c) { graph.add_node(Turbine::Node.new(:c)) }
    let(:d) { graph.add_node(Turbine::Node.new(:d)) }
    let(:e) { graph.add_node(Turbine::Node.new(:e)) }

    before do
      a.connect_to(b, :friend)
      b.connect_to(c, :friend)
      c.connect_to(a, :sibling)
      d.connect_to(a, :friend)
      e.connect_to(b, :friend)
    end

    # ------------------------------------------------------------------------

    it 'returns strongly connected components' do
      components = Turbine::Algorithms::Tarjan.new(graph).
        strongly_connected_components

      expect(components).to include([a, b, c])
      expect(components).to include([d])
      expect(components).to include([e])
    end

    it 'returns strongly connected components by label' do
      components = Turbine::Algorithms::Tarjan.new(graph, :friend).
        strongly_connected_components

      expect(components).to include([a])
      expect(components).to include([b])
      expect(components).to include([c])
      expect(components).to include([d])
      expect(components).to include([e])

      expect(components).to_not include([a, b, c])
    end

    it 'returns an array when sorting' do
      sorted = Turbine::Algorithms::Tarjan.new(graph, :friend).tsort
      expect(sorted).to be_a(Array)
    end

    it 'raises an error when sorting is impossible' do
      expect { Turbine::Algorithms::Tarjan.new(graph).tsort }.
        to raise_error(TSort::Cyclic)
    end
  end # Algorithms::Tarjan
end # Turbine
