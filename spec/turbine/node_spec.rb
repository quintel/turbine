require 'spec_helper'

describe 'Turbine::Node' do
  let(:node) { Turbine::Node.new(:phil) }

  context 'creating a new node' do
    context 'without providing a key' do
      it { expect(-> { Turbine::Node.new }).to raise_error(ArgumentError) }
    end

    context 'providing no properties' do
      it 'should not set any proeprties' do
        expect(Turbine::Node.new(:a).properties).to be_empty
      end
    end

    context 'providing a properties hash' do
      it 'should not set any proeprties' do
        expect(Turbine::Node.new(:a, { b: 2, c: 3 }).properties).
          to eql(b: 2, c: 3)
      end
    end
  end

  describe '#in_edges' do
    subject { node.in_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#out_edges' do
    subject { node.out_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#in' do
    let(:phil)   { Turbine::Node.new(:phil) }
    let(:claire) { Turbine::Node.new(:claire) }
    let(:haley)  { Turbine::Node.new(:haley) }
    let(:alex)   { Turbine::Node.new(:alex) }
    let(:luke)   { Turbine::Node.new(:luke) }

    before do
      claire.connect_to(luke, :child)
      phil.connect_to(luke, :child)
      haley.connect_to(luke, :sibling)
      alex.connect_to(luke)
    end

    subject { luke.in }
    it { should be_kind_of(Enumerable) }

    context 'with no label' do
      subject { luke.in }

      it 'should return all in nodes' do
        expect(subject).to have(4).members
      end

      it { should include(phil) }
      it { should include(claire) }
      it { should include(haley) }
      it { should include(alex) }

      it 'should filter the in_edges' do
        expect(luke.in_edges).to have(4).members
      end
    end # with no label

    context 'with a label' do
      subject { luke.in(:child) }

      it 'should return all in nodes' do
        expect(subject).to have(2).members
      end

      it { should include(phil) }
      it { should include(claire) }

      it 'should filter the in_edges' do
        expect(luke.in_edges(:child)).to have(2).members
      end
    end
  end

  describe '#out' do
    let(:phil)   { Turbine::Node.new(:phil) }
    let(:claire) { Turbine::Node.new(:claire) }
    let(:haley)  { Turbine::Node.new(:haley) }
    let(:alex)   { Turbine::Node.new(:alex) }
    let(:luke)   { Turbine::Node.new(:luke) }

    before do
      luke.connect_to(claire, :parent)
      luke.connect_to(phil,   :parent)
      luke.connect_to(haley,  :sibling)
      luke.connect_to(alex)
    end

    subject { luke.out }
    it { should be_kind_of(Enumerable) }

    context 'with no label' do
      subject { luke.out }

      it 'should return all in nodes' do
        expect(subject).to have(4).members
      end

      it { should include(phil) }
      it { should include(claire) }
      it { should include(haley) }
      it { should include(alex) }

      it 'should not filter the out_edges' do
        expect(luke.out_edges).to have(4).members
      end
    end # with no label

    context 'with a label' do
      subject { luke.out(:parent) }

      it 'should return all in nodes' do
        expect(subject).to have(2).members
      end

      it { should include(phil) }
      it { should include(claire) }

      it 'should filter the out_edges' do
        expect(luke.out_edges(:parent)).to have(2).members
      end
    end
  end # #out

  describe '#connect_to' do
    let(:claire) { Turbine::Node.new(:claire) }
    let(:haley)  { Turbine::Node.new(:haley) }

    context 'when establishing a new connection' do
      let!(:result) { claire.connect_to(haley) }

      it 'sets up an "out" edge on the node' do
        expect(claire.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the argument' do
        expect(haley.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end

      it 'sets no label on the edge' do
        expect(result.label).to be_nil
      end
    end # when establishing a new connection

    context 'with a label' do
      let!(:result) { claire.connect_to(haley, :child) }

      it 'sets the label on the edge' do
        expect(result.label).to eql(:child)
      end
    end # with a label

    context 'when connecting to self' do
      let!(:result) { claire.connect_to(claire) }

      it 'sets up an "out" edge on the node' do
        expect(claire.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the node' do
        expect(claire.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end
    end # when connecting to self

    context 'when an identical edge already exists' do
      let!(:original) { claire.connect_to(haley, :child) }

      it 'raises DuplicateEdgeError' do
        expect(-> { claire.connect_to(haley, :child) }).
          to raise_error(Turbine::DuplicateEdgeError)
      end
    end # when an identical edge already exists
  end # connect_to

  describe '#connect_via' do
    let(:jay)    { Turbine::Node.new(:jay) }
    let(:gloria) { Turbine::Node.new(:gloria) }
    let(:edge)   { Turbine::Edge.new(jay, gloria, :spouse) }

    context %(when the node is the edge's "in") do
      let!(:result) { gloria.connect_via(edge) }

      it %(adds the edge to the node's "in" edges) do
        expect(gloria.in_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        context 'with different labels' do
          let(:other) { Turbine::Edge.new(jay, gloria, :lives_with) }
          before      { gloria.connect_via(other) }

          it 'retains the original edge' do
            expect(gloria.in_edges).to include(edge)
          end

          it 'adds the new edge' do
            expect(gloria.in_edges).to include(other)
          end
        end # and a duplicate edge already exists
      end # with different labels

      context 'with identical labels' do
        let(:other) { Turbine::Edge.new(jay, gloria, :spouse) }

        it 'raises a DuplicateEdgeError' do
          expect(->{ gloria.connect_via(other) }).
            to raise_error(Turbine::DuplicateEdgeError)
        end
      end # with identical labels
    end # when the node is the edge's "in"

    context %(when the node is the edge's "out") do
      let!(:result) { jay.connect_via(edge) }

      it %(adds the edge to the node's "out" edges) do
        expect(jay.out_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        context 'with different labels' do
          let(:other) { Turbine::Edge.new(jay, gloria, :lives_with) }
          before      { jay.connect_via(other) }

          it 'retains the original edge' do
            expect(jay.out_edges).to include(edge)
          end

          it 'adds the new edge' do
            expect(jay.out_edges).to include(other)
          end
        end # with different labels

        context 'with identical labels' do
          let(:other) { Turbine::Edge.new(jay, gloria, :spouse) }

          it 'raises a DuplicateEdgeError' do
            expect(->{ jay.connect_via(other) }).
              to raise_error(Turbine::DuplicateEdgeError)
          end
        end # with identical labels
      end # and a duplicate edge already exists
    end # when the node is the edge's "out"

    context 'when the edge is a loop' do
      let(:edge)    { Turbine::Edge.new(jay, jay) }
      let!(:result) { jay.connect_via(edge) }

      it %(adds the edge to the node's "out" edges) do
        expect(jay.out_edges).to include(edge)
      end

      it %(adds the edge to the node's "in" edges) do
        expect(jay.in_edges).to include(edge)
      end

      it 'returns the edge' do
        expect(result).to eql(edge)
      end

      context 'and a duplicate edge already exists' do
        let(:other) { Turbine::Edge.new(jay, jay) }

        it 'raises a DuplicateEdgeError' do
          expect(->{ jay.connect_via(other) }).
            to raise_error(Turbine::DuplicateEdgeError)
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
