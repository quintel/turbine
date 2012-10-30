require 'spec_helper'

module Turbine::Pipeline
  describe Trace do
    context 'on a simple pipeline' do
      let(:pipeline) { Pump.new([1, 2, 3]) | Sender.new(:*, 2) | Trace.new }

      it 'returns one value for each input' do
        expect(pipeline.to_a).to have(3).members
      end

      it 'includes the original value for each input' do
        result = pipeline.to_a

        expect(result[0].first).to eql(1)
        expect(result[1].first).to eql(2)
        expect(result[2].first).to eql(3)
      end

      it 'includes the intermediate value for each input' do
        result = pipeline.to_a

        expect(result[0].last).to eql(2)
        expect(result[1].last).to eql(4)
        expect(result[2].last).to eql(6)
      end
    end # on a simple pipeline
  end # Trace
end # Turbine::Pipeline
