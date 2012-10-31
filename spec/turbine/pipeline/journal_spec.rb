require 'spec_helper'

module Turbine::Pipeline
  describe Journal do
    context 'with an upstream/downstream transform' do
      let(:pipe) do
        Pump.new([4, 8, 16]) | ->(x) { x * 10 } |
          Journal.new(:a) | ->(x) { x / 5.0 }
      end

      let(:journal) { pipe.source }

      it 'remembers the upstream values' do
        pipe.next
        expect(journal.values).to eql([40, 80, 160])
      end

      it 'does not affect the outcome of the pipeline' do
        expect(pipe.to_a).to eql([8.0, 16.0, 32.0])
      end

      it 'forgets stored values when rewound' do
        pipe.to_a
        pipe.rewind

        journal.source.should_receive(:next).and_raise(StopIteration)

        journal.values
      end

      it 'requires that a name be provided' do
        expect { Journal.new }.to raise_error(ArgumentError)
      end

      describe '#include?' do
        it 'includes known values' do
          expect(journal).to include(40)
          expect(journal).to include(80)
          expect(journal).to include(160)
        end

        it 'does not include unknown values' do
          expect(journal).to_not include(nil)
          expect(journal).to_not include(0)
          expect(journal).to_not include(true)
          expect(journal).to_not include(4)
          expect(journal).to_not include(8.0)
        end
      end
    end # with an upstream/downstream transform

    context 'with a valueless source' do
      let(:pipe) { Pump.new([]) | Journal.new(:a) }

      it 'emits nothing' do
        expect(pipe.to_a).to eql([])
      end

      it 'remembers no values' do
        pipe.to_a
        expect(pipe.values).to eql([])
      end
    end # with a valueless source
  end # Journal

  describe Journal::Read do
    class Reader < Segment
      include Journal::Read
    end

    let(:pump) { Pump.new([3, 6, 9]) | ->(x) { x * 10 } }

    context 'when there is a non-matching upstream journal' do
      let(:pipe) do
        pump | Journal.new(:no) | ->(x) { x * 2 } | Reader.new
      end

      it 'raises an error' do
        expect { pipe.journal(:yes) }.
          to raise_error(/no such upstream journal: :yes/i)
      end
    end

    context 'when there are no upstream journals' do
      let(:pipe) { pump | Reader.new }

      it 'raises an error' do
        expect { pipe.journal(:yes) }.
          to raise_error(/no such upstream journal: :yes/i)
      end
    end

    context 'when there is a matching upstream journal' do
      let(:pipe) do
        pump | Journal.new(:yes) | ->(x) { x * 2 } | Reader.new
      end

      it 'retrieves values from the nearest one' do
        expect(pipe.journal(:yes).values).to eql([30, 60, 90])
      end
    end

    context 'when there are multiple matching upstream journals' do
      let(:pipe) do
        pump | Journal.new(:yes) | ->(x) { x * 2 } |
          Journal.new(:yes) | Reader.new
      end

      it 'retrieves values from the nearest one' do
        expect(pipe.journal(:yes).values).to eql([60, 120, 180])
      end
    end
  end # Journal::Read
end # Turbine::Pipeline
