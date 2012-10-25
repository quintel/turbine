require 'spec_helper'

module Turbine::Pipeline
  describe Sender do
    Target = Struct.new(:score)

    context 'when the source item responds to the message' do
      let(:pipeline) do
        pump = Pump.new([ Target.new(10), Target.new(42), Target.new(1337) ])
        send = Sender.new(:score)

        pump | send
      end

      it 'returns the result of the message' do
        expect(pipeline.next).to eql(10)
        expect(pipeline.next).to eql(42)
        expect(pipeline.next).to eql(1337)
      end
    end # when the source item responds to the message

    context 'when the source item returns several results' do
      let(:source)   { ['a bc', 'def hij klm', 'nop', 'q'] }
      let(:pipeline) { Pump.new(source) | Sender.new(:split, ' ') }

      it 'yields each result in turn' do
        expect(pipeline.to_a[0..1]).to eql(%w( a bc ))
      end

      it 'later continues with the upstream items' do
        expect(pipeline.to_a[2..-1]).to eql(%w( def hij klm nop q))
      end

      context 'and the source has an empty array' do
        let(:source) { ['a bc', '', 'def'] }

        it 'skips to the next present value' do
          expect(pipeline.to_a).to eql(%w( a bc def ))
        end
      end
    end # when the source item returns several results

    context 'when the source item returns nested arrays' do
      let(:source)   { ['abc', [['d'], ['e']], 'fgh', []] }
      let(:pipeline) { Pump.new(source) | Sender.new(:length) }

      it 'does not recuse into nested arrays' do
        expect(pipeline.to_a).to eql([3, 2, 3, 0])
      end
    end # when the source item returns nested arrays

    context 'when the source item returns a Collection' do
      let(:source)   { [
        Target.new(Turbine::Collection.new([9])),
        Target.new(Turbine::Collection.new([8, 7])),
        Target.new(Turbine::Collection.new([6, 5]))
      ] }

      let(:pipeline) { Pump.new(source) | Sender.new(:score) }

      it 'expands each collection' do
        expect(pipeline.to_a).to eql([9, 8, 7, 6, 5])
      end
    end

    context 'when the source item is an enumerator' do
      let(:source) do
        [ Target.new([1, 2].to_enum), Target.new([3, 4].to_enum) ]
      end

      let(:pipeline) { Pump.new(source) | Sender.new(:score) }

      it 'expands the enumerators' do
        expect(pipeline.to_a).to eql([1, 2, 3, 4])
      end
    end

    context 'chaining multiple Senders' do
      let(:pipeline) do
        Pump.new([1, 2, 3]) | Sender.new(:*, 10) | Sender.new(:to_s)
      end
    end

    context 'when the source item raises an error' do
      let(:pipeline) { (Pump.new([->{ raise 'Oops!' }]) | Sender.new(:call)) }

      it 'propagates the error' do
        expect { pipeline.next }.to raise_error(/Oops!/)
      end
    end # when the source item raises an error

    context 'when the message is to a private method' do
      let(:klass)    { Class.new { private ; def nope ; end } }
      let(:pipeline) { Pump.new([klass.new]) | Sender.new(:nope) }

      it 'raises an error' do
        # We can't test explicitly for the "private method" message, since
        # rbx has a different message when using `public_send`.
        expect { pipeline.next }.to raise_error(NoMethodError)
      end
    end # when the message is to a private method

    context 'when the message is to a non-existent method' do
      let(:pipeline) { Pump.new(['']) | Sender.new(:__invalid__) }

      it 'raises an error' do
        expect { pipeline.next }.to raise_error(/undefined method/)
      end
    end # when the message is to a non-existent method

    describe '#to_s' do
      let(:pipeline) { Pump.new([]) | Sender.new(:out, :child, true) }

      it 'shows the current segment name' do
        expect(pipeline.to_s).to include('Sender')
      end

      it 'shows the current message name' do
        expect(pipeline.to_s).to include('[out(')
      end

      it 'shows arguments' do
        expect(pipeline.to_s).to end_with(':child, true)]')
      end
    end # to_s
  end # Sender
end # Turbine::Pipeline
