require 'spec_helper'

describe 'Turbine::Traversal::Base' do
  describe '#visit' do
    it 'should raise NotImplementedError' do
      enum = Turbine::Traversal::Base.new(Turbine::Node.new(:a), :out).to_enum
      expect(->{ enum.each { |*| } }).to raise_error(NotImplementedError)
    end
  end
end
