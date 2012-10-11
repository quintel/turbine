require 'spec_helper'

describe 'Turbine::Collection' do
  let(:claire) { Turbine::Node.new(:claire) }
  let(:phil)   { Turbine::Node.new(:phil) }
  let(:haley)  { Turbine::Node.new(:haley) }
  let(:alex)   { Turbine::Node.new(:alex) }
  let(:luke)   { Turbine::Node.new(:luke) }

  let(:parent_collection) { Turbine::Collection.new([claire, phil]) }
  let(:child_collection)  { Turbine::Collection.new([haley, alex, luke]) }

  before do
    [ haley, alex, luke ].each do |child|
      claire.connect_to(child, :child)
      phil.connect_to(child,   :child)
      child.connect_to(claire, :parent)
      child.connect_to(phil,   :parent)
    end
  end

  # --------------------------------------------------------------------------

  describe '#method_missing' do
    it 'should defer to each member of the collection' do
      expect(child_collection.out(:parent).out(:children)).
        to be_a(Turbine::Collection)
    end

    it 'should work when an item returns a single element' do
      haley.connect_to(luke, :brother)
      expect(child_collection.out_edges(:brother).out).to have(1).member
    end

    it 'should contain only unique elements' do
      expect(child_collection.out(:parent)).to have(2).members
    end
  end # #method_missingo

  # --------------------------------------------------------------------------

  describe '#+' do
    let(:result) { parent_collection + child_collection }

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should add the collections together' do
      expect(result).to have(5).members
    end

    it 'should not modify the original collections' do
      expect(parent_collection).to have(2).members
      expect(child_collection).to have(3).members
    end
  end

  # --------------------------------------------------------------------------

  describe '#-' do
    let(:result) { parent_collection - Turbine::Collection.new([claire]) }

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should subtract the collections' do
      expect(result).to have(1).member
      expect(result.to_a).to eql([phil])
    end
  end

  # --------------------------------------------------------------------------

  describe '#&' do
    let(:result) do
      parent_collection &
        Turbine::Collection.new([claire, haley, alex])
    end

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should contain only elements common to both collections' do
      expect(result).to have(1).member
      expect(result.to_a).to eql([claire])
    end
  end

  # --------------------------------------------------------------------------

  describe '#|' do
    let(:result) do
      parent_collection |
        Turbine::Collection.new([claire, haley, alex])
    end

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should contain elements of both collections' do
      expect(result).to have(4).members
      expect(result.to_a).to eql([claire, phil, haley, alex])
    end
  end

  # --------------------------------------------------------------------------

  describe '#map' do
    let(:result) do
      parent_collection.map(&:out_edges)
    end

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should contain as many elements as the original' do
      expect(result).to have(parent_collection.length).members
    end
  end

  # --------------------------------------------------------------------------

  describe '#select' do
    let(:result) do
      parent_collection.select { |e| e.key == :phil }
    end

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should contain only matching elements' do
      expect(result.to_a).to eql([phil])
    end
  end

  # --------------------------------------------------------------------------

  describe '#reject' do
    let(:result) do
      parent_collection.reject { |e| e.key == :phil }
    end

    it 'should return a collection' do
      expect(result).to be_a(Turbine::Collection)
    end

    it 'should contain only matching elements' do
      expect(result.to_a).to eql([claire])
    end
  end

  # --------------------------------------------------------------------------

  describe '#==' do
    it 'should return true when both have identical members' do
      other = Turbine::Collection.new([claire, phil])
      expect(parent_collection == other).to be_true
    end

    it 'does not care about collection order' do
      other = Turbine::Collection.new([phil, claire])
      expect(parent_collection == other).to be_true
    end

    it 'should return false when the collections are different' do
      expect(parent_collection == Turbine::Collection.new([phil])).to be_false
    end
  end

end # Turbine::Collection
