require 'spec_helper'

module Turbine::Pipeline
  describe Traverse do
    let(:a) { Turbine::Node.new(:a) }
    let(:b) { Turbine::Node.new(:b) }
    let(:c) { Turbine::Node.new(:c) }

    before do
      a.connect_to(b, :energy)
      b.connect_to(c, :energy)
    end

    let(:pipe) { Pump.new([a]) | Traverse.new(:out) }

    it 'emits each descendant of the source node' do
      expect(pipe.to_a).to eql([b, c])
    end

    it 'cannot support tracing' do
      expect { pipe | Trace.new }.
        to raise_error(Turbine::NotTraceableError)
    end
  end # Traverse
end # Turbine::Pipeline
