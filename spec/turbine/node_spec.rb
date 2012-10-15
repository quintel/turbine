require 'spec_helper'

describe 'Turbine::Node' do
  let(:phil)   { Turbine::Node.new(:phil, gender: :male) }
  let(:claire) { Turbine::Node.new(:claire, gender: :female) }
  let(:haley)  { Turbine::Node.new(:haley, gender: :female) }
  let(:alex)   { Turbine::Node.new(:alex, gender: :female) }
  let(:luke)   { Turbine::Node.new(:luke, gender: :male) }
  let(:dylan)  { Turbine::Node.new(:dylan, gender: :male) }

  before do
    [ haley, alex, luke ].each do |child|
      claire.connect_to(child, :child)
      phil.connect_to(child, :child)
    end

    phil.connect_to(claire, :spouse)
    claire.connect_to(phil, :spouse)

    haley.connect_to(dylan, :boyfriend)
    dylan.connect_to(haley, :girlfriend)
  end

  # --------------------------------------------------------------------------

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

  # --------------------------------------------------------------------------

  describe '#in_edges' do
    it { expect(haley.in_edges).to be_kind_of(Enumerable) }

    it 'should return all edges when not filtering' do
      expect(haley.in_edges).to have(3).members
    end

    it 'should filter the in_edges with an edge label' do
      expect(haley.in_edges(:child)).to have(2).members
    end

    it 'should filter edges with a block' do
      expect(haley.in_edges { |e| e.out.get(:gender) == :male }).
        to have(2).members
    end
  end

  # --------------------------------------------------------------------------

  describe '#out_edges' do
    it { expect(haley.out_edges).to be_kind_of(Enumerable) }

    it 'should return all edges when not filtering' do
      expect(phil.out_edges).to have(4).members
    end

    it 'should filter the out_edges with an edge label' do
      expect(phil.out_edges(:child)).to have(3).members
    end

    it 'should filter edges with a block' do
      expect(phil.out_edges { |e| e.in.get(:gender) == :female }).
        to have(3).member
    end
  end

  # --------------------------------------------------------------------------

  describe '#in' do
    it { expect(luke.in).to be_kind_of(Enumerable) }

    context 'with no label' do
      subject { luke.in }

      it 'should return all in nodes' do
        expect(subject).to have(2).members
      end

      it { should include(phil) }
      it { should include(claire) }
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
    end # with a label
  end # in

  # --------------------------------------------------------------------------

  describe '#out' do
    it { expect(claire.out).to be_kind_of(Enumerable) }

    context 'with no label' do
      subject { claire.out }

      it 'should return all out nodes' do
        expect(subject).to have(4).members
      end

      it { should include(phil) }
      it { should include(haley) }
      it { should include(alex) }
      it { should include(luke) }
    end # with no label

    context 'with a label' do
      subject { claire.out(:child) }

      it 'should return all in nodes' do
        expect(subject).to have(3).members
      end

      it { should include(haley) }
      it { should include(alex) }
      it { should include(luke) }
    end # with a label
  end # #out

  # --------------------------------------------------------------------------

  describe '#connect_to' do
    let(:gloria) { Turbine::Node.new(:gloria) }
    let(:manny)  { Turbine::Node.new(:manny) }

    context 'when establishing a new connection' do
      let!(:result) { gloria.connect_to(manny) }

      it 'sets up an "out" edge on the node' do
        expect(gloria.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the argument' do
        expect(manny.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end

      it 'sets no label on the edge' do
        expect(result.label).to be_nil
      end
    end # when establishing a new connection

    context 'with a label' do
      let!(:result) { gloria.connect_to(manny, :child) }

      it 'sets the label on the edge' do
        expect(result.label).to eql(:child)
      end
    end # with a label

    context 'when connecting to self' do
      let!(:result) { gloria.connect_to(gloria) }

      it 'sets up an "out" edge on the node' do
        expect(gloria.out_edges).to include(result)
      end

      it 'sets up an "in" edge on the node' do
        expect(gloria.in_edges).to include(result)
      end

      it 'returns the edge' do
        expect(result).to be_a(Turbine::Edge)
      end
    end # when connecting to self

    context 'when an identical edge already exists' do
      let!(:original) { gloria.connect_to(manny, :child) }

      it 'raises DuplicateEdgeError' do
        expect(-> { gloria.connect_to(manny, :child) }).
          to raise_error(Turbine::DuplicateEdgeError)
      end
    end # when an identical edge already exists
  end # connect_to

  # --------------------------------------------------------------------------

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
    end # adding the same edge twice
  end # connect_via

  # --------------------------------------------------------------------------

end
