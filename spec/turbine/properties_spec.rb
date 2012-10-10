require 'spec_helper'

describe 'Turbine::Properties' do
  Widget = Class.new do
    include Turbine::Properties
  end

  let(:model) { Widget.new }

  # --------------------------------------------------------------------------

  describe '#properties' do
    it 'should return a Hash when no value has been initialized' do
      expect(model.properties).to eql({})
    end

    it 'should return the properties hash when a value has been assigned' do
      model.properties = original = { a: 1, b: 2 }
      expect(model.properties).to equal(original)
    end
  end

  # --------------------------------------------------------------------------

  describe '#set' do
    let!(:result) { model.set(:type, 'Extra-special') }

    it 'sets the value' do
      expect(model.get(:type)).to eql('Extra-special')
    end

    it 'returns the value' do
      expect(result).to eql('Extra-special')
    end
  end

end
