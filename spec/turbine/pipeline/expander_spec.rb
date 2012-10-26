require 'spec_helper'

module Turbine::Pipeline
  describe Expander do
    context 'given a non-iterable value' do
      let(:pipeline) { Pump.new([1, 2]) | Expander.new }

      it 'yields each value from the upstream segment' do
        expect(pipeline.to_a).to eql([1, 2])
      end
    end # given a non-iterable value

    context 'given an Array' do
      let(:pipeline) { Pump.new([[1, 2], 3, [4, 5]]) | Expander.new }

      it 'yields each value from the array' do
        expect(pipeline.to_a).to eql([1, 2, 3, 4, 5])
      end
    end # given an array

    context 'given an Enumerator' do
      let(:pipeline) { Pump.new([[1, 2].to_enum, [3]]) | Expander.new }

      it 'yields each value from the enumerator' do
        expect(pipeline.to_a).to eql([1, 2, 3])
      end
    end # given an Enumerator
  end # Expander
end # Turbine::Pipeline
