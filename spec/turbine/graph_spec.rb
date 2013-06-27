require 'spec_helper'

describe 'Turbine::Graph' do
  let(:graph)  { Turbine::Graph.new         }
  let(:node)   { Turbine::Node.new(:jay)    }
  let(:other)  { Turbine::Node.new(:gloria) }

  describe 'adding a new node' do
    context 'when the graph is empty' do
      before { graph.add(node) }

      it 'should add the node' do
        expect(graph.node(:jay)).to eql(node)
      end

      it 'should be included in the "nodes" enumerable' do
        expect(graph.nodes).to include(node)
      end
    end # when the graph is empty

    context 'when another non-conflicting node exists' do
      before do
        graph.add(other)
        graph.add(node)
      end

      it 'should add the node' do
        expect(graph.node(:jay)).to eql(node)
      end

      it 'should retain the other node' do
        expect(graph.node(:gloria)).to eql(other)
      end

      it 'should be included in the "nodes" enumerable' do
        expect(graph.nodes).to include(node)
      end

      it 'should include the other node in the "nodes" enumerable' do
        expect(graph.nodes).to include(other)
      end

      it 'should draw an edge between them' do
        expect(graph.node(:jay).connect_to(other)).to be_an Turbine::Edge
      end
    end # when another non-conflicting node exists

    context 'when the key conflicts with an existing node' do
      before { graph.add(node) }

      it 'should raise a DuplicateNodeError' do
        expect(->{ graph.add(Turbine::Node.new(:jay)) }).to raise_error(
          Turbine::DuplicateNodeError, /Graph already has a node with the key/)
      end
    end # when the key conflicts with an existing node
  end # adding a new node

  describe 'removing a node' do
    context 'when the node is not a member of the graph' do
      it 'raises NoSuchNodeError' do
        expect { graph.delete(Turbine::Node.new(:nope)) }.
          to raise_error(Turbine::NoSuchNodeError, /:nope/)
      end
    end # when the node is not a member of the graph

    context 'when the node is a member of the graph' do
      before :each do
        graph.add(node)
        graph.add(other)
      end

      let!(:edge_one) { node.connect_to(other, :spouse) }
      let!(:edge_two) { other.connect_to(node, :spouse) }
      let!(:result)   { graph.delete(node) }

      it 'returns the removed node' do
        expect(result).to eql(node)
      end

      it 'removes the node from the graph' do
        expect(graph.nodes).to_not include(node)
      end

      it 'removes outward edges from the removed node' do
        expect(node.out_edges).to_not include(edge_one)
      end

      it 'removes inward edges from the removed node' do
        expect(node.in_edges).to_not include(edge_two)
      end

      it 'removes outward edges from surviving nodes' do
        expect(other.out_edges).to_not include(edge_two)
      end

      it 'removes inward edges from surviving nodes' do
        expect(other.in_edges).to_not include(edge_one)
      end
    end
  end # removing a node

  describe '#inspect' do
    before do
      graph.add(node)
      graph.add(other)
      node.connect_to(other, :test)
    end

    it 'should show the number of nodes' do
      expect(graph.inspect).to include('2 nodes')
    end

    it 'should show the number of edges' do
      expect(graph.inspect).to include('1 edges')
    end
  end # inspect

  describe '#tsort' do
    it 'returns an array when doing an unfiltered sort' do
      expect(graph.tsort).to be_an(Array)
    end

    it 'returns an array when doing a by-label sort' do
      expect(graph.tsort(:spouse)).to be_an(Array)
    end

    it 'returns an array when doing a filtered sort' do
      expect(graph.tsort { |*| true }).to be_an(Array)
    end
  end # tsort

end # Turbine::Graph
