require 'spec_helper'

describe 'Turbine::Edge' do
  context 'creating a new edge' do
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
