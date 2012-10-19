require 'spec_helper'

module Turbine::Pipeline
  describe Pump do
    let(:pump) { Pump.new([10, 100, 1000]) }

    # ------------------------------------------------------------------------

    describe '#next' do
      it 'returns each value in the source' do
        expect(pump.next).to eql(10)
        expect(pump.next).to eql(100)
        expect(pump.next).to eql(1000)
      end

      it 'does raises StopIteration when there are no values remaining' do
        3.times { pump.next }
        expect { pump.next }.to raise_error(StopIteration)
      end
    end

    # ------------------------------------------------------------------------

    describe '#each' do
      it 'yields each item in turn' do
        expected = [10, 100, 1000]

        pump.each { |value| expect(value).to eql(expected.shift) }
      end
    end

    # ------------------------------------------------------------------------

  end # Pump
end # Turbine::Pipeline
