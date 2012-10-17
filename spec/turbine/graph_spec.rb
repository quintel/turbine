require 'spec_helper'

describe 'Turbine::Graph' do
  let(:graph)  { Turbine::Graph.new         }
  let(:node)   { Turbine::Node.new(:jay)    }
  let(:other)  { Turbine::Node.new(:gloria) }

  describe 'adding a new node' do
    context 'when the graph is empty' do
      before { graph.add_node(node) }

      it 'should add the node' do
        expect(graph.node(:jay)).to eql(node)
      end

      it 'should be included in the "nodes" enumerable' do
        expect(graph.nodes).to include(node)
      end
    end # when the graph is empty

    context 'when another non-conflicting node exists' do
      before do
        graph.add_node(other)
        graph.add_node(node)
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
      before { graph.add_node(node) }

      it 'should raise a DuplicateNodeError' do
        expect(->{ graph.add_node(Turbine::Node.new(:jay)) }).to raise_error(
          Turbine::DuplicateNodeError, /Graph already has a node with the key/)
      end
    end # when the key conflicts with an existing node
  end # adding a new node

  describe '#inspect' do
    before do
      graph.add_node(node)
      graph.add_node(other)
      node.connect_to(other, :test)
    end

    it 'should show the number of nodes' do
      expect(graph.inspect).to include('2 nodes')
    end

    it 'should show the number of edges' do
      expect(graph.inspect).to include('1 edges')
    end
  end
end # Turbine::Graph
