require 'spec_helper'

module Turbine
  describe Algorithms::Johnson do
    let(:graph) { Turbine::Graph.new }
    let(:algo)  { Algorithms::Johnson.new(graph, label: :circular) }

    let(:a) { graph.add(Turbine::Node.new(:a)) }
    let(:b) { graph.add(Turbine::Node.new(:b)) }
    let(:c) { graph.add(Turbine::Node.new(:c)) }
    let(:d) { graph.add(Turbine::Node.new(:d)) }
    let(:e) { graph.add(Turbine::Node.new(:e)) }

    before do
      a.connect_to(b, :friend)
      b.connect_to(c, :friend)
      c.connect_to(a, :circular)
      d.connect_to(a, :friend)
      e.connect_to(b, :friend)

      graph
    end

    # ------------------------------------------------------------------------

    it 'picks correct start pairs' do
      start_pairs = []
      algo.start_pairs { |n1, n2| start_pairs << [n1, n2] }

      expect(start_pairs).to include([c, a])
      expect(start_pairs).to_not include([a, c])
    end

    it 'finds a circuit starting from node c' do
      algo.discover_circuits
      expect(algo.discovered).to include([c, a, b, c])
    end

    context 'with a graph with two circularities from c' do
      before do
        c.connect_to(e, :circular)
      end

      it 'picks correct start pairs' do
        start_pairs = []
        algo.start_pairs { |n1, n2| start_pairs << [n1, n2] }

        expect(start_pairs).to include([c, a])
        expect(start_pairs).to include([c, e])
      end

      it 'finds two circuits starting from node c' do
        algo.discover_circuits
        expect(algo.discovered).to include([c, a, b, c])
        expect(algo.discovered).to include([c, e, b, c])
      end
    end

    context 'with a graph with two seperate circularities' do
      let(:f) { graph.add(Turbine::Node.new(:f)) }

      before do
        f.connect_to(e, :circular)
        b.connect_to(f, :friend)
      end

      it 'picks correct start pairs' do
        start_pairs = []
        algo.start_pairs { |n1, n2| start_pairs << [n1, n2] }

        expect(start_pairs).to include([c, a])
        expect(start_pairs).to include([f, e])
      end

      it 'finds circuits starting from nodes c and f' do
        algo.discover_circuits
        expect(algo.discovered).to include([c, a, b, c])
        expect(algo.discovered).to include([f, e, b, f])
      end
    end
  end # Algorithms::Johnson
end # Turbine
