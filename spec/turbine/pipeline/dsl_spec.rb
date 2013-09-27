require 'spec_helper'

module Turbine::Pipeline
  describe DSL do
    def dsl(source = [])
      Turbine::Pipeline.dsl(source)
    end

    context 'calling a "sender" with arguments' do
      let(:pipe) { dsl.get(:thing) }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Sender' do
        expect(pipe.source).to be_a(Sender)
      end

      it 'sets the message to be sent' do
        expect(pipe.source.message).to eql(:get)
      end

      it 'sets the additional arguments' do
        expect(pipe.source.args).to eql([:thing])
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # calling a "sender" with arguments

    context 'filtering with "select"' do
      let(:pipe) { dsl.select { |v| v } }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Filter' do
        expect(pipe.source).to be_a(Filter)
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # filtering with select

    context 'filtering with "reject"' do
      let(:pipe) { dsl.reject { |v| v } }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Filter' do
        expect(pipe.source).to be_a(Filter)
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # filtering with reject

    context 'transforming with "map"' do
      let(:pipe) { dsl.map { |v| v } }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Transform' do
        expect(pipe.source).to be_a(Transform)
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # transforming with map

    context 'multiple sub-pipes with "split"' do
      let(:pipe) { dsl.split(->(x) { x }) }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be Split' do
        expect(pipe.source).to be_a(Split)
      end
    end # multiple sub-pipes with "split"

    context 'multiple sub-pipes with "also"' do
      let(:pipe) { dsl.also(->(x) { x }) }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be Also' do
        expect(pipe.source).to be_a(Also)
      end
    end # multiple sub-pipes with "also"

    context 'filtering with uniq' do
      let(:pipe) { dsl.uniq }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Unique' do
        expect(pipe.source).to be_a(Unique)
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # filtering with uniq

    context 'iterating with "each"' do
      let(:pipe) { dsl([1, 2, 3]) }

      it 'yields each result in turn' do
        result = []
        pipe.each { |value| result.push(value) }

        expect(result).to eql([1, 2, 3])
      end
    end # iterating with each

    context 'realising the full result with "to_a"' do
      let(:pipe) { dsl([4, 5, 6]).map { |v| v * 2 } }

      it 'returns an array' do
        expect(pipe.to_a).to be_a(Array)
      end

      it 'returns the full result' do
        expect(pipe.to_a).to eql([8, 10, 12])
      end
    end # realising the full result with to_a

    context 'storing upstream results with "as"' do
      let(:pipe) { dsl([1, 3, 5]).as(:original) }

      it 'adds a Journal segment' do
        expect(pipe.source).to be_a(Journal)
      end

      it 'sets the journal name' do
        expect(pipe.source.name).to eql(:original)
      end
    end # storing upstream results with "as"

    context 'journal filtering with "only"' do
      let(:pipe) { dsl([1]).as(:orig).only(:orig) }

      it 'adds a JournalFilter segment' do
        expect(pipe.source).to be_a(JournalFilter)
      end

      it 'sets the journal mode to :only' do
        expect(pipe.source.inspect).to include('only(:orig)')
      end
    end

    context 'journal filtering with "except"' do
      let(:pipe) { dsl([1]).as(:orig).except(:orig) }

      it 'adds a JournalFilter segment' do
        expect(pipe.source).to be_a(JournalFilter)
      end

      it 'sets the journal mode to :except' do
        expect(pipe.source.inspect).to include('except(:orig)')
      end
    end

    context 'getting the value trace' do
      context 'on an unfiltered pipeline' do
        let(:pipe) { dsl([7, 14]).map { |x| x * 1.5 }.trace }

        it 'returns an array' do
          expect(pipe.to_a).to be_a(Array)
        end

        it 'returns value traces for each input' do
          expect(pipe.to_a).to eql([[7, 10.5], [14, 21.0]])
        end
      end # on an unfiltered pipeline

      context 'on a pipeline with filters' do
        let(:pipe) do
          dsl([5, 10, 15]).select { |x| x > 9 }.map { |x| x - 1 }.trace
        end

        it 'returns an array' do
          expect(pipe.to_a).to be_a(Array)
        end

        it 'emits filter-passing values' do
          expect(pipe.to_a).to include([10, 9])
          expect(pipe.to_a).to include([15, 14])
        end

        it 'omits filter-failing values' do
          expect(pipe.to_a).to_not include([5, 4])
        end
      end # on a pipeline with filters
    end # getting the value trace

    context 'showing the path string' do
      let(:pipe) { dsl([1, 2, 3]).map { |v| v * 2 } }

      it 'returns a string' do
        expect(pipe.to_s).to eql('Pump | Transform')
      end
    end # showing the path string

    context 'inspecting the pipeline' do
      let(:pipe) { dsl([1, 2, 3]).map { |v| v * 2 } }

      it 'should show the final result' do
        expect(pipe.inspect).to eql('[2, 4, 6]')
      end
    end # inspecting the pipeline
  end # DSL
end # Turbine::Pipeline
