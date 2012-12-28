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
      it 'should not set any properties' do
        expect(Turbine::Node.new(:a).properties).to be_empty
      end
    end

    context 'providing a properties hash' do
      it 'should not set any properties' do
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
        expect(-> { gloria.connect_to(manny, :child) }).to raise_error(
          Turbine::DuplicateEdgeError, /another edge already exists/i)
      end
    end # when an identical edge already exists

    context 'with properties' do
      let!(:result) { gloria.connect_to(manny, :child, type: :ok) }

      it 'should assign the properties to the edge' do
        expect(result.get(:type)).to eql(:ok)
      end
    end # with properties
  end # connect_to

  # --------------------------------------------------------------------------

  describe '#disconnect_from' do
    context 'when given no label' do
      context 'and there is an edge between the two nodes' do
        let!(:edge) { haley.out_edges(:boyfriend).first }
        let!(:also) { haley.connect_to(dylan, :knows) }
        before { haley.disconnect_from(dylan) }

        it 'removes the outward edges from the receiver' do
          expect(haley.out_edges).to_not include(edge)
          expect(haley.out_edges).to_not include(also)
        end

        it 'removes the inward edge from the target' do
          expect(dylan.in_edges).to_not include(edge)
          expect(dylan.in_edges).to_not include(also)
        end
      end

      context 'and there is no edge between the two nodes' do
        it 'raises no error' do
          expect { phil.disconnect_from(dylan) }.to_not raise_error
        end
      end
    end # when given no label

    context 'when given a label' do
      let!(:retained) { haley.connect_to(dylan, :knows) }
      let!(:removed)  { haley.out_edges(:boyfriend).first }

      context 'and there is a matching edge between the two nodes' do
        before { haley.disconnect_from(dylan, :boyfriend) }

        it 'removes the outward edge from the receiver' do
          expect(haley.out_edges).to_not include(removed)
        end

        it 'removes the inward edge from the target' do
          expect(dylan.in_edges).to_not include(removed)
        end

        it 'does not remove outward edges with a different label' do
          expect(haley.out_edges).to include(retained)
        end

        it 'does not remove inward edges with a different label' do
          expect(dylan.in_edges).to include(retained)
        end
      end

      context 'and there is no matching edge between the two nodes' do
        it 'raises no error' do
          expect { haley.disconnect_from(dylan, :nope) }.to_not raise_error
        end
      end
    end # when given a label
  end # disconnect_from

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

  describe '#properties' do
    context 'initialized with a properties hash' do
      it 'should be able to change the properties' do
        node = Turbine::Node.new(:foo, {demand: 100})
        node.set(:demand, 101)

        expect(node.get(:demand)).to eql(101)
        expect(node.properties).to eql(demand: 101)
      end
    end # initialized with a properties hash

    context 'initialized without a properties hash' do
      it 'should be able to change the properties' do
        node = Turbine::Node.new(:foo)
        node.set(:demand, 100)
        expect(node.properties).to eql(demand: 100)
      end
    end # initialized without a properties hash
  end # #properties

  # --------------------------------------------------------------------------

  describe '#descendants' do
    it 'should be a pipeline DSL' do
      expect(phil.descendants).to be_a(Turbine::Pipeline::DSL)
    end

    context 'with no label restriction' do
      let(:descendants) { phil.descendants.to_a }

      it 'returns all nodes connected by "out" edges' do
        expect(descendants).to have(5).nodes
      end

      it 'should include immediately adjacent descendants' do
        expect(descendants).to include(haley)  # phil -child-> haley
        expect(descendants).to include(alex)   # phil -child-> alex
        expect(descendants).to include(luke)   # phil -child-> luke
        expect(descendants).to include(claire) # phil -spouse-> claire
      end

      it 'should recurse through descendants' do
        # phil -child-> haley -boyfriend-> dylan
        expect(descendants).to include(dylan)
      end
    end # with no label restriction

    context 'with a label restriction' do
      let(:jay) { Turbine::Node.new(:jay) }
      let(:descendants) { jay.descendants(:child).to_a }

      before do
        jay.connect_to(claire, :child)
      end

      it 'returns all matching nodes connected by "out" edges' do
        expect(descendants).to have(4).nodes
      end

      it 'should include immediately adjacent descendants' do
        # jay -child-> claire
        expect(descendants).to include(claire)
      end

      it 'should recurse through descendants' do
        # jay -child-> claire -child-> haley
        expect(descendants).to include(haley)

        # jay -child-> claire -child-> alex
        expect(descendants).to include(alex)

        # jay -child-> claire -child-> luke
        expect(descendants).to include(luke)
      end

      it 'should not include non-matching nodes' do
        expect(descendants).to_not include(phil)
        expect(descendants).to_not include(dylan)
      end
    end # with no label restriction
  end # #descendants

  # --------------------------------------------------------------------------

  describe '#ancestors' do
    it 'should be an pipeline DSL' do
      expect(phil.ancestors).to be_a(Turbine::Pipeline::DSL)
    end

    context 'with no label restriction' do
      let(:jay) { Turbine::Node.new(:jay) }
      let(:descendants) { haley.ancestors.to_a }

      before do
        jay.connect_to(claire, :child)
      end

      it 'returns all nodes connected by "out" edges' do
        expect(descendants).to have(4).nodes
      end

      it 'should include immediately adjacent descendants' do
        expect(descendants).to include(claire) # claire -child-> haley
        expect(descendants).to include(phil)   # phil -child-> haley
        expect(descendants).to include(dylan)  # dylan -girlfriend-> haley
      end

      it 'should recurse through ancestors' do
        # jay -child-> claire -child-> haley
        expect(descendants).to include(jay)
      end
    end # with no label restriction

    context 'with a label restriction' do
      let(:jay) { Turbine::Node.new(:jay) }
      let(:descendants) { haley.ancestors(:child).to_a }

      before do
        jay.connect_to(claire, :child)
      end

      it 'returns all matching nodes connected by "out" edges' do
        expect(descendants).to have(3).nodes
      end

      it 'should include immediately adjacent descendants' do
        # claire -child-> haley
        expect(descendants).to include(claire)

        # phil -child-> haley
        expect(descendants).to include(phil)
      end

      it 'should recurse through ancestors' do
        # jay -child-> claire -child-> haley
        expect(descendants).to include(jay)
      end

      it 'should not include non-matching nodes' do
        expect(descendants).to_not include(alex)
        expect(descendants).to_not include(luke)
        expect(descendants).to_not include(dylan)
      end
    end # with a label restriction
  end # #descendants

  %w( inspect to_s ).each do |method|
    describe "##{ method }" do
      it 'includes the class type' do
        expect(phil.public_send(method)).to include('Turbine::Node')
      end

      it 'includes the node key' do
        expect(phil.public_send(method)).to include('phil')
      end
    end
  end # ( inspect to_s ).each

end
