require 'spec_helper'

module Turbine
  describe Algorithms::Tarjan do
    let(:graph) { Turbine::Graph.new }

    let(:a) { graph.add(Turbine::Node.new(:a)) }
    let(:b) { graph.add(Turbine::Node.new(:b)) }
    let(:c) { graph.add(Turbine::Node.new(:c)) }
    let(:d) { graph.add(Turbine::Node.new(:d)) }
    let(:e) { graph.add(Turbine::Node.new(:e)) }

    before do
      a.connect_to(b, :friend)
      b.connect_to(c, :friend)
      c.connect_to(a, :sibling)
      d.connect_to(a, :friend)
      e.connect_to(b, :friend)
    end

    # ------------------------------------------------------------------------

    it 'returns strongly connected components' do
      components = graph.strongly_connected_components

      expect(components).to include([a, b, c])
      expect(components).to include([d])
      expect(components).to include([e])
    end

    it 'returns strongly connected components by label' do
      components = graph.strongly_connected_components(:friend)

      expect(components).to include([a])
      expect(components).to include([b])
      expect(components).to include([c])
      expect(components).to include([d])
      expect(components).to include([e])

      expect(components).to_not include([a, b, c])
    end

    it 'returns an array when sorting' do
      expect(graph.tsort(:friend)).to be_a(Array)
    end

    it 'raises an error when sorting is impossible' do
      expect { graph.tsort }.to raise_error(Turbine::CyclicError)
    end
  end # Algorithms::Tarjan
end # Turbine
