require 'spec_helper'

describe 'Turbine::Edge' do
  context 'creating a new edge' do
    let(:left)  { Turbine::Node.new(:gloria) }
    let(:right) { Turbine::Node.new(:jay) }
    let(:edge)  { Turbine::Edge.new(left, right, :married) }

    it 'should assign the in node' do
      expect(edge.in).to eql(right)
    end

    it 'should assign the out node' do
      expect(edge.out).to eql(left)
    end

    it 'should assign the label' do
      expect(edge.label).to eql(:married)
    end

    context 'without an "in" node' do
      it { expect(->{ Turbine::Edge.new }).to raise_error(ArgumentError) }
    end

    context 'without an "out" node' do
      it do
        expect(->{ Turbine::Edge.new(Turbine::Node.new(:gloria)) }).
          to raise_error(ArgumentError)
      end
    end
  end # creating a new edge
end # Turbine::Edge
