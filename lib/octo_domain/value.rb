# frozen_string_literal: true

require "active_support"

module OctoDomain
  # Value is a base class for value objects and provides useful functionality
  # for value objects.
  #
  # @abstract
  class Value
    # Converts a result from an internal domain object into a value object that
    # can be passed to the application layer or other domains.
    #
    # @param result [Object] the result from the domain object
    # @param attribute_map [Hash] a map of value object attributes to domain object methods
    # @return [Value] the value object
    def self.from(result, attribute_map:)
      new.tap do |value|
        attribute_map.each do |name, method|
          value.public_send(:"#{name}=", result.public_send(method))
        end
      end
    end
  end
end
