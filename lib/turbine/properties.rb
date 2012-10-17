module Turbine
  module Properties

    # Public: Returns the properties associated with the model.
    #
    # Returns a hash containing the properties. This is the original
    # properties hash, not a duplicate.
    def properties
      @properties ||= Hash.new
    end

    # Public: Mass-assigns properties to the model.
    #
    # new_props - A hash containing zero or more properties. The internal
    #             properties hash is set to whatever parameters you provide; a
    #             duplicate is not made before assignment. You may provide
    #             +nil+ to remove all properties.
    #
    # Returns the properties.
    def properties=(new_props)
      unless new_props.is_a?(Hash) || new_props.nil?
        raise InvalidPropertiesError.new(self, new_props)
      end

      @properties = new_props
    end

    # Public: Sets a single property on the model.
    #
    # key   - The property name.
    # value - The value to be set.
    #
    # Returns the value.
    def set(key, value)
      properties[key] = value
    end

    # Public: Returns a single property on the model.
    #
    # key - The property to be retrieved.
    #
    # Returns the value or nil if the property does not exist.
    def get(key)
      properties[key]
    end

  end # Properties
end # Turbine
