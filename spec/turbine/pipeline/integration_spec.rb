require 'spec_helper'

module Turbine::Pipeline
  describe 'Pipeline' do
    context 'Transform -> Filter' do
      let(:pipeline) do
        pump      = Pump.new([1, 2, 3, 4, 5])
        transform = Transform.new { |x| x * 10 }
        filter    = Filter.new    { |x| x > 30 }

        (pump | transform | filter)
      end

      it 'runs the pipeline for each value' do
        expect(pipeline.next).to eql(40)
        expect(pipeline.next).to eql(50)
      end

      it 'does not return untransformed values' do
        array = pipeline.to_a

        [1, 2, 3, 4, 5].each do |source|
          expect(array).to_not include(source)
        end
      end

      it 'does not return filtered values' do
        array = pipeline.to_a

        [10, 20, 30].each do |source|
          expect(array).to_not include(source)
        end
      end
    end # Transform -> Filter

    context 'Filter -> Transform' do
      let(:pipeline) do
        pump      = Pump.new((40..50).to_a)
        filter    = Filter.new    { |x| x == 42 }
        transform = Transform.new { |x| x / 2 }

        (pump | filter | transform)
      end

      it 'runs the pipeline for each value' do
        expect(pipeline.next).to eql(21)
      end

      it 'does not return untransformed values' do
        array = pipeline.to_a

        (40..50).each do |source|
          expect(array).to_not include(source)
        end
      end
    end # Filter -> Transform

    describe 'Laziness' do
      let(:pump)      { Pump.new(1..10) }
      let(:transform) { Transform.new { |x| x } }
      let(:finalise)  { Transform.new { |x| x * 2 } }
      let(:pipeline)  { pump | transform | finalise }

      it 'call each segment the minimum number of times' do
        transform.should_receive(:next).
          exactly(2).times.and_return { pump.next }

        2.times { pipeline.next }
      end

      it 'calls each segment when requesting all items' do
        # Once for each item, then once more to check for another...
        transform.should_receive(:next).
          exactly(11).times.and_return { pump.next }

        pipeline.to_a
      end
    end # Laziness

    describe '#take' do
      let(:pump)     { Pump.new((1..10).to_a) }
      let(:filter)   { Filter.new { |*| true } }
      let(:pipeline) { pump | filter }

      it 'returns the requested number of items' do
        expect(pipeline.take(4)).to eql([1, 2, 3, 4])
      end

      it 'returns the full collection when requesting too many items' do
        expect(pipeline.take(20)).to eql((1..10).to_a)
      end

      it 'executes lazily' do
        filter.should_receive(:next).
          exactly(3).times.and_return { pump.next }

        pipeline.take(3)
      end

      it 'rewinds on each call' do
        pipeline.take(2)
        expect(pipeline.take(3)).to eql([1, 2, 3])
      end
    end # #take
  end # Pipeline
end # Turbine::Pipeline
