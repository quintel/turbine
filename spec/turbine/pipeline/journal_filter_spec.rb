require 'spec_helper'

module Turbine::Pipeline
  describe JournalFilter do
    context 'when retaining journal values' do
      let(:pipe) do
        Pump.new([1, 2, 3, 4, 2, 5]) | Journal.new(:int) |
          ->(x) { x * 2 } | JournalFilter.new(:only, :int)
      end

      it 'emits items which were present in the journal' do
        expect(pipe.to_a).to eql([2, 4, 4])
      end

      it 'sets the mode to "only"' do
        expect(pipe.inspect).to match(/only\(:int\)$/)
      end
    end

    context 'when excluding journal values' do
      let(:pipe) do
        Pump.new([1, 2, 3, 4, 2, 5]) | Journal.new(:int) |
          ->(x) { x * 2 } | JournalFilter.new(:except, :int)
      end

      it 'emits items which were present in the journal' do
        expect(pipe.to_a).to eql([6, 8, 10])
      end

      it 'sets the mode to "except"' do
        expect(pipe.inspect).to match(/except\(:int\)$/)
      end
    end

    context 'with an invalid filter mode' do
      it 'raises an error' do
        expect { JournalFilter.new(:every, :thing) }.
          to raise_error(ArgumentError)
      end
    end

    context 'when the upstream journal does not exist' do
      it 'raises an error' do
        expect { Pump.new([]) | JournalFilter.new(:only, :int) }.
          to raise_error(/no such upstream journal/i)
      end
    end
  end # JournalFilter
end # Turbine::Pipeline
