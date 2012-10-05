require 'spec_helper'

describe 'Turbine::Edge' do
  context 'creating a new edge' do
    context 'without an "in" vertex' do
      it { expect(->{ Turbine::Edge.new }).to raise_error(ArgumentError) }
    end

    context 'without an "out" vertex' do
      it do
        expect(->{ Turbine::Edge.new(Turbine::Vertex.new(:gloria)) }).
          to raise_error(ArgumentError)
      end
    end
  end # creating a new edge
end # Turbine::Edge
