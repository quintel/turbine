require 'spec_helper'

module Turbine::Pipeline
  describe Segment do
    let(:segment) { Segment.new.tap { |s| s.source = [1, 2, 3].to_enum } }

    # ------------------------------------------------------------------------

    describe '#append' do
      it 'appends the new Segment' do
        other = Segment.new
        segment.append(other)

        expect(other.source).to equal(segment)
      end

      it 'returns the new Segment' do
        other = Segment.new
        expect(segment.append(other)).to equal(other)
      end

      it 'appends a block using Transform' do
        expect(segment.append(->(x) { x })).to be_a(Transform)
      end
    end # append

    # ------------------------------------------------------------------------

    describe '#next' do
      it 'returns each item from the source' do
        expect(segment.next).to eql(1)
        expect(segment.next).to eql(2)
        expect(segment.next).to eql(3)
      end

      it 'does raises StopIteration when all items have been used' do
        3.times { segment.next }
        expect { segment.next }.to raise_error(StopIteration)
      end
    end

    # ------------------------------------------------------------------------

    describe '#each' do
      it 'yields each item in the source' do
        results = []
        segment.each { |value| results.push(value) }

        expect(results).to eql([1, 2, 3])
      end
    end

    # ------------------------------------------------------------------------

    describe '#to_s' do
      let(:pipeline) do
        Pump.new([]) | Segment.new | Segment.new
      end

      it 'shows the current segment name' do
        expect(pipeline.to_s).to end_with('Segment')
      end

      it 'shows the previous segment names' do
        expect(pipeline.to_s).to start_with('Pump | Segment')
      end
    end

  end # describe Segment
end # Turbine::Pipeline
