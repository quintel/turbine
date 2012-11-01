require 'spec_helper'

module Turbine::Pipeline
  describe Split do
    context 'when given no branches' do
      it 'should raise ArgumentError' do
        expect { Split.new }.to raise_error(ArgumentError)
      end
    end

    context 'when a branch is invalid' do
      it 'should raise a NoMethodError' do
        expect { Split.new(->(x) { x }, ->(x) { x.invalid }) }.
          to raise_error(NoMethodError)
      end
    end

    context 'given two branches' do
      let(:a) { Turbine::Node.new(:a, name: 'Alpha')   }
      let(:b) { Turbine::Node.new(:b, name: 'Bravo')   }
      let(:c) { Turbine::Node.new(:c, name: 'Charlie') }

      let(:pump) { Pump.new([ a, b, c ]) }
      let(:pipe) { pump | Split.new(->(n) { n }, ->(n) { n.get(:name) }) }

      # ----------------------------------------------------------------------

      it 'should return each value' do
        expect(pipe.to_a).to eql([ a, 'Alpha', b, 'Bravo', c, 'Charlie' ])
      end
    end
  end # Split

  describe Also do
    let(:node) { Turbine::Node.new(:a, type: :long, area: :north) }
    let(:pump) { Pump.new([node]) }

    context 'given a single branch' do
      let(:pipe) { pump | Also.new(->(x) { x.get(:type) }) }

      it 'yields the input first' do
        expect(pipe.next).to eql(node)
      end

      it 'yields the result of the branch second' do
        pipe.next
        expect(pipe.next).to eql(:long)
      end
    end

    context 'given multple branches' do
      let(:pipe) do
        pump | Also.new(->(x) { x.get(:type) }, ->(x) { x.get(:area) })
      end

      it 'yields the input first' do
        expect(pipe.next).to eql(node)
      end

      it 'yields the result of the first branch next' do
        pipe.next
        expect(pipe.next).to eql(:long)
      end

      it 'yields the result of the second branch last' do
        2.times { pipe.next }
        expect(pipe.next).to eql(:north)
      end
    end

    context 'given a block' do
      let(:pipe) { pump | Also.new { |x| x.get(:area) } }

      it 'yields the input first' do
        expect(pipe.next).to eql(node)
      end

      it 'yields the result of the block next' do
        pipe.next
        expect(pipe.next).to eql(:north)
      end
    end

    context 'given a block and branch' do
      let(:pipe) do
        pump | Also.new(->(x) { x.get(:area) }) { |x| x.get(:type) }
      end

      it 'yields the input first' do
        expect(pipe.next).to eql(node)
      end

      it 'yields the result of the branches next' do
        pipe.next
        expect(pipe.next).to eql(:north)
      end

      it 'yields the result of the block last' do
        2.times { pipe.next }
        expect(pipe.next).to eql(:long)
      end
    end
  end # Also
end # Turbine::Pipeline
