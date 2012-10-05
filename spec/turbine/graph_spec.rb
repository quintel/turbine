require 'spec_helper'

describe 'Turbine::Graph' do
  describe 'adding a new vertex' do
    let(:graph)  { Turbine::Graph.new }
    let(:vertex) { Turbine::Vertex.new(:jay) }

    context 'when the graph is empty' do
      before { graph.add_vertex(vertex) }

      it 'should add the vertex' do
        expect(graph.vertex(:jay)).to eql(vertex)
      end

      it 'should be included in the "vertices" enumerable' do
        expect(graph.vertices).to include(vertex)
      end
    end # when the graph is empty

    context 'when another non-conflicting vertex exists' do
      let(:other) { Turbine::Vertex.new(:gloria) }

      before do
        graph.add_vertex(other)
        graph.add_vertex(vertex)
      end

      it 'should add the vertex' do
        expect(graph.vertex(:jay)).to eql(vertex)
      end

      it 'should retain the other vertex' do
        expect(graph.vertex(:gloria)).to eql(other)
      end

      it 'should be included in the "vertices" enumerable' do
        expect(graph.vertices).to include(vertex)
      end

      it 'should include the other vertex in the "vertices" enumerable' do
        expect(graph.vertices).to include(other)
      end
    end # when another non-conflicting vertex exists

    context 'when the key conflicts with an existing vertex' do
      before { graph.add_vertex(vertex) }

      it 'should raise a DuplicateVertex error' do
        expect(->{ graph.add_vertex(Turbine::Vertex.new(:jay)) }).
          to raise_error(Turbine::DuplicateVertex)
      end
    end # when the key conflicts with an existing vertex
  end # adding a new vertex
end # Turbine::Graph
