require 'spec_helper'

module Turbine
  describe Algorithms::FilteredTarjan do
    let(:graph) { Turbine::Graph.new }
    let(:algo)  { Algorithms::FilteredTarjan.new(graph) { |e| e.get(:tsort) } }

    let(:a) { graph.add(Turbine::Node.new(:a)) }
    let(:b) { graph.add(Turbine::Node.new(:b)) }
    let(:c) { graph.add(Turbine::Node.new(:c)) }
    let(:d) { graph.add(Turbine::Node.new(:d)) }
    let(:e) { graph.add(Turbine::Node.new(:e)) }

    before do
      a.connect_to(b, :friend, tsort: true)
      b.connect_to(c, :friend, tsort: true)
      c.connect_to(a, :friend, tsort: false)
      d.connect_to(a, :friend, tsort: true)
      e.connect_to(b, :friend, tsort: true)

      graph
    end

    # ------------------------------------------------------------------------

    it 'returns strongly connected components by label' do
      components = algo.strongly_connected_components

      expect(components).to include([a])
      expect(components).to include([b])
      expect(components).to include([c])
      expect(components).to include([d])
      expect(components).to include([e])

      expect(components).to_not include([a, b, c])
    end

    it 'does not warn about being cyclic' do
      expect { algo.tsort }.to_not raise_error
    end

    it 'returns an array when sorting' do
      expect(algo.tsort).to be_a(Array)
    end
  end # Algorithms::Tarjan
end # Turbine
