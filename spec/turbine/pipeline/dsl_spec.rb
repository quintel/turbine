require 'spec_helper'

module Turbine::Pipeline
  describe DSL do
    def dsl(source = [])
      Turbine::Pipeline.dsl(source)
    end

    context 'calling a "sender" with no arguments' do
      let(:pipe) { dsl.out }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Sender' do
        expect(pipe.source).to be_a(Sender)
      end

      it 'sets the message to be sent' do
        expect(pipe.source.message).to eql(:out)
      end

      it 'sets no arguments to be called' do
        expect(pipe.source.args).to be_empty
      end

      it 'has a Pump upstream' do
        expect(pipe.source.source).to be_a(Pump)
      end
    end # calling a "sender" with no arguments

    context 'calling a "sender" with arguments' do
      let(:pipe) { dsl.in(:child) }

      it 'returns a DSL' do
        expect(pipe).to be_a(DSL)
      end

      it 'sets the source to be a Sender' do
        expect(pipe.source).to be_a(Sender)
      end

      it 'sets the message to be sent' do
        expect(pipe.source.message).to eql(:in)
      end

      it 'sets no arguments to be called' do
        expect(pipe.source.args).to eql([:child])
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
  end # DSL
end # Turbine::Pipeline
