require 'spec_helper'

module Turbine::Pipeline
  describe Transform do
    let(:pump) { Pump.new([15, 30, 45]) }

    # ------------------------------------------------------------------------

    context 'with a simple transform block' do
      let(:transform) { pump.append(Transform.new { |x| x * 2 }) }

      it 'tranforms each value according to the block' do
        expect(transform.next).to eql(30)
        expect(transform.next).to eql(60)
        expect(transform.next).to eql(90)
      end

      it 'yields once per source value' do
        expect(transform.to_a).to have(3).members
      end
    end # with a simple tranform block

    # ------------------------------------------------------------------------

    context 'with a subclass implementing `transform`' do
      let(:transform) do
        pump.append(Class.new(Transform) do
          def transform(value) ; value.to_f / 2 ; end
        end.new)
      end

      it 'tranforms each value according to the block' do
        expect(transform.next).to eql(7.5)
        expect(transform.next).to eql(15.0)
        expect(transform.next).to eql(22.5)
      end

      it 'yields once per source value' do
        expect(transform.to_a).to have(3).members
      end
    end # with a subclass implementing `transform`

    # ------------------------------------------------------------------------

    context 'with no block and no `transform` method' do
      let(:transform) { pump.append(Transform.new) }

      it 'returns each value untouched' do
        expect(transform.next).to eql(15)
        expect(transform.next).to eql(30)
        expect(transform.next).to eql(45)
      end

      it 'yields once per source value' do
        expect(transform.to_a).to have(3).members
      end
    end # with no block and no `transform` method

    # ------------------------------------------------------------------------

  end # Transform
end # Turbine::Pipeline
