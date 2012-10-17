require 'spec_helper'

describe 'Turbine::Traversal::DepthFirst' do
  %w( a b c d e f g h ).each do |key|
    let!(key.to_sym) { Turbine::Node.new(key.to_sym) }
  end

  #       A
  #      / \
  #     B   C
  #    /   / \
  #   D   E   F
  #  /   /
  # G   H
  before do
    a.connect_to(b, :likes)
    b.connect_to(d, :hates)
    d.connect_to(g, :likes)
    a.connect_to(c, :likes)
    c.connect_to(e, :likes)
    e.connect_to(h, :hates)
    c.connect_to(f, :likes)
  end

  context 'with no restriction on the edge label' do
    let(:enum) { Turbine::Traversal::DepthFirst.new(a, :out).to_enum.to_a }

    it 'should contain all the nodes adjacent nodes' do
      expect(enum).to have(7).nodes
    end

    it 'should not contain the starting node' do
      expect(enum).to_not include(a)
    end

    it 'should traverse left-to-right' do
      expect(enum.index(b)).to be < enum.index(c)
    end

    it 'should traverse by depth before breadth' do
      expect(enum.index(d)).to be < enum.index(c)
    end
  end # with no restriction on the edge label

  context 'with an edge label restriction' do
    let(:enum) do
      Turbine::Traversal::DepthFirst.new(a, :out, [:likes]).to_enum.to_a
    end

    it 'should contain only nodes connected using the label' do
      expect(enum).to have(4).nodes

      expect(enum).to include(b)
      expect(enum).to include(c)
      expect(enum).to include(e)
      expect(enum).to include(f)
    end
  end # with an edge label restriction

  context '#next' do
    let(:enum) { Turbine::Traversal::DepthFirst.new(a, :out).to_enum }

    it 'should retrieve each node in turn' do
      members = []

      begin
        while member = enum.next
          members << member
          expect(member).to be_a(Turbine::Node)
        end
      rescue StopIteration
      end

      expect(members).to have(7).nodes
    end

    it 'should raise StopIteration when finished' do
      expect(->{
        while enum.next do ; end
      }).to raise_error(StopIteration)
    end

    it 'should permit rewinding' do
      first  = enum.next
      second = enum.next

      enum.rewind

      expect(enum.next).to equal(first)
      expect(enum.next).to equal(second)
    end
  end # #next
end
