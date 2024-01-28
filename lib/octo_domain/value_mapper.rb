# frozen_string_literal: true

module OctoDomain
  # @!visibility private
  class ValueMapper
    attr_reader :name, :value_class

    def initialize(name, value_class)
      @name = name
      @value_class = value_class
    end

    def attribute(field)
      attributes << field.to_sym

      value_class.define_method(field) do
        instance_variable_get(:"@#{field}")
      end

      value_class.define_method(:"#{field}=") do |value|
        instance_variable_set(:"@#{field}", value)
      end
    end

    def attributes
      @attributes ||= Set.new
    end

    def serialize(result)
      attribute_map = attributes.map { |a| [a, a] }.to_h
      value_class.from(result, attribute_map: attribute_map)
    end
  end
end
