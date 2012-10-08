require 'spec_helper'

describe 'Turbine::Vertex' do
  let(:vertex) { Turbine::Vertex.new(:phil) }

  context 'creating a new vertex' do
    context 'without providing a key' do
      it { expect(-> { Turbine::Vertex.new }).to raise_error(ArgumentError) }
    end
  end

  describe '#in_edges' do
    subject { vertex.in_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#out_edges' do
    subject { vertex.out_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#in' do
    subject { vertex.in }
    it { should be_kind_of(Enumerable) }
  end

  describe '#out' do
    subject { vertex.out }
    it { should be_kind_of(Enumerable) }
  end

  describe '#connect_to' do
    let(:claire) { Turbine::Vertex.new(:claire) }
    let(:haley)  { Turbine::Vertex.new(:haley) }

    context 'when establishing a new connection' do
      let!(:result) { claire.connect_to(haley) }

      it 'sets up an "out" edge on the vertex' do
        expect(claire.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the argument' do
        expect(haley.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end
    end # when establishing a new connection

    context 'when connecting to self' do
      let!(:result) { claire.connect_to(claire) }

      it 'sets up an "out" edge on the vertex' do
        expect(claire.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the vertex' do
        expect(claire.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end
    end # when connecting to self

    context 'when an identical edge already exists' do
      let!(:original) { claire.connect_to(haley) }
      let!(:new_edge) { claire.connect_to(haley) }

      it 'adds a new edge' do
        expect(original).to_not eql(new_edge)
      end
    end # when an identical edge already exists
  end # connect_to

  describe '#connect_via' do
    let(:jay)    { Turbine::Vertex.new(:jay) }
    let(:gloria) { Turbine::Vertex.new(:gloria) }
    let(:edge)   { Turbine::Edge.new(jay, gloria) }

    context %(when the vertex is the edge's "in") do
      let!(:result) { gloria.connect_via(edge) }

      it %(adds the edge to the vertex's "in" edges) do
        expect(gloria.in_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        let!(:other) { Turbine::Edge.new(jay, gloria) }
        before       { gloria.connect_via(other) }

        it 'retains the original edge' do
          expect(gloria.in_edges).to include(edge)
        end

        it 'adds the new edge' do
          expect(gloria.in_edges).to include(other)
        end
      end # and a duplicate edge already exists
    end # when the vertex is the edge's "in"

    context %(when the vertex is the edge's "out") do
      let!(:result) { jay.connect_via(edge) }

      it %(adds the edge to the vertex's "out" edges) do
        expect(jay.out_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        let!(:other) { Turbine::Edge.new(jay, gloria) }
        before       { jay.connect_via(other) }

        it 'retains the original edge' do
          expect(jay.out_edges).to include(edge)
        end

        it 'adds the new edge' do
          expect(jay.out_edges).to include(other)
        end
      end # and a duplicate edge already exists
    end # when the vertex is the edge's "out"

    context 'when the edge is a loop' do
      let(:edge)    { Turbine::Edge.new(jay, jay) }
      let!(:result) { jay.connect_via(edge) }

      it %(adds the edge to the vertex's "out" edges) do
        expect(jay.out_edges).to include(edge)
      end

      it %(adds the edge to the vertex's "in" edges) do
        expect(jay.in_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        let!(:other) { Turbine::Edge.new(jay, jay) }
        before       { jay.connect_via(other) }

        it 'retains the original edge' do
          expect(jay.in_edges).to include(edge)
          expect(jay.out_edges).to include(edge)
        end

        it 'adds the new edge' do
          expect(jay.in_edges).to include(other)
          expect(jay.out_edges).to include(other)
        end
      end # and a duplicate edge already exists
    end # when the edge is a loop

    context 'adding the same edge twice' do
      it 'does not add the edge a second time' do
        gloria.connect_via(edge)
        gloria.connect_via(edge)

        expect(gloria.in_edges.select { |e| e == edge }).to have(1).member
      end
    end
  end # connect_via

end
