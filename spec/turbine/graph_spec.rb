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

      it 'should raise DuplicateEdge Error when two nodes get two edges' do
        graph.node(:jay).connect_to(other)
        expect(->{ graph.node(:jay).connect_to(other) }).
         to raise_error(Turbine::DuplicateEdgeError)
      end
    end # when another non-conflicting node exists

    context 'when the key conflicts with an existing node' do
      before { graph.add_node(node) }

      it 'should raise a DuplicateNodeError' do
        expect(->{ graph.add_node(Turbine::Node.new(:jay)) }).
          to raise_error(Turbine::DuplicateNodeError)
      end
    end # when the key conflicts with an existing node
  end # adding a new node
end # Turbine::Graph
