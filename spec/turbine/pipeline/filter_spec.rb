require 'spec_helper'

module Turbine::Pipeline
  describe Filter do
    let(:pump) { Pump.new([40, 41, 42, 43, 44]) }

    # ------------------------------------------------------------------------

    context 'with a simple filter block' do
      let(:filter) { pump.append(Filter.new { |x| x % 2 == 0 }) }

      it 'yields only those values for which the filter is true' do
        expect(filter.next).to eql(40)
        expect(filter.next).to eql(42)
        expect(filter.next).to eql(44)
      end

      it 'yields once per filtered source value' do
        expect(filter.to_a).to have(3).members
      end
    end # with a simple filter block

    # ------------------------------------------------------------------------

    context 'with a subclass implementing `filter`' do
      let(:filter) do
        pump.append(Class.new(Filter) do
          def filter(value) ; value == 42 ; end
        end.new)
      end

      it 'yields only those values for which the filter is true' do
        expect(filter.next).to eql(42)
      end

      it 'yields once per filtered source value' do
        expect(filter.to_a).to have(1).member
      end
    end # with a subclass implementing `filter`

    # ------------------------------------------------------------------------

    context 'with no block and no `filter` method' do
      let(:filter) { pump.append(Filter.new) }

      it 'yields all the values in the source' do
        [40, 41, 42, 43, 44].each do |value|
          expect(filter.next).to eql(value)
        end
      end

      it 'yields once per filtered source value' do
        expect(filter.to_a).to have(5).members
      end
    end # with no block and no `filter` method

    # ------------------------------------------------------------------------

  end # Filter
end # Turbine::Pipeline
