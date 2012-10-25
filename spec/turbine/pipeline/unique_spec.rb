require 'spec_helper'

module Turbine::Pipeline
  describe Unique do
    let(:pump) { Pump.new([1, 1, 2, 3, 4, 2, 1, 5, 6]) }

    # ------------------------------------------------------------------------

    context 'with no fetcher block' do
      let(:filter) { pump.append(Unique.new) }

      it 'allows only unique elements to pass' do
        expect(filter.to_a).to eql([1, 2, 3, 4, 5, 6])
      end

      it 'resets the seen values when rewound' do
        filter.to_a
        expect(filter.to_a).to eql([1, 2, 3, 4, 5, 6])
      end
    end

    # ------------------------------------------------------------------------

    context 'with a fetcher block' do
      let(:filter) { pump.append(Unique.new { |x| x / 3 }) }

      it 'allows only values with a unique fetched value to pass' do
        expect(filter.to_a).to eql([1, 3, 6])
      end
    end

  end # Unique
end # Turbine::Pipeline
