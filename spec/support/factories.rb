module Turbine::Spec
  module Factories
    # Public: Registers a new factory.
    #
    # For example
    #   Factories.register(:family) do |graph|
    #     jay    = graph.add_node(Turbine::Node.new(:jay))
    #     gloria = graph.add_node(Turbine::Node.new(:gloria))
    #     manny  = graph.add_node(Turbine::Node.new(:manny))
    #
    #     jay.connect_to(:gloria, :spouse)
    #
    #     # ...
    #   end
    #
    # Returns nothing.
    def self.register(name, &factory)
      @factories ||= {}

      if @factories.key?(name)
        raise ArgumentError, "A factory called #{name.inspect} already exists"
      end

      @factories[name] = factory

      nil
    end

    # Public: Instantiates a new graph which was previously registered with
    # Factories with +name+. Each call returns a totally new graph.
    #
    # Returns a Graph.
    def self.create(name)
      Turbine::Graph.new.tap { |graph| @factories.fetch(name).call(graph) }
    end

    # Public: Convenience method for use in specs. See Factories.create.
    #
    # Returns a graph.
    def factory(name)
      Factories.create(name)
    end
  end # Factories
end # Turbine::Spec
