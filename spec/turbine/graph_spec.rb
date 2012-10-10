require 'spec_helper'

describe 'Turbine::Graph' do
  describe 'adding a new node' do
    let(:graph)  { Turbine::Graph.new }
    let(:node) { Turbine::Node.new(:jay) }

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
      let(:other) { Turbine::Node.new(:gloria) }

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
    end # when another non-conflicting node exists

    context 'when the key conflicts with an existing node' do
      before { graph.add_node(node) }

      it 'should raise a DuplicateNode error' do
        expect(->{ graph.add_node(Turbine::Node.new(:jay)) }).
          to raise_error(Turbine::DuplicateNode)
      end
    end # when the key conflicts with an existing node
  end # adding a new node
end # Turbine::Graph
