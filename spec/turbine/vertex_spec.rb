require 'spec_helper'

describe 'Turbine::Vertex' do
  let(:vertex) { Turbine::Vertex.new }

  describe '#in_edges' do
    subject { vertex.in_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#out_edges' do
    subject { vertex.out_edges }
    it { should be_kind_of(Enumerable) }
  end

  describe '#in' do
    subject { vertex.in }
    it { should be_kind_of(Enumerable) }
  end

  describe '#out' do
    subject { vertex.out }
    it { should be_kind_of(Enumerable) }
  end
end
