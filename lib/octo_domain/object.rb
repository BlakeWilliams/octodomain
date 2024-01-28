# frozen_string_literal: true

module OctoDomain
  # DomainObject represents a domain object that is converted from an
  # ActiveRecord model. It is used to represent the data that is passed between
  # the  application and the domain layer.
  class DomainObject
    attr_reader :name, :domain_class

    def initialize(name, domain_class)
      @name = name
      @domain_class = domain_class
    end

    def attribute(field)
      @_attributes ||= {}
      @_attributes[field.to_sym] = @domain_class

      @domain_class.define_method(field) do
        instance_variable_get("@#{field}")
      end

      @domain_class.define_method("#{field}=") do |value|
        instance_variable_set("@#{field}", value)
      end
    end

    def attributes
      @_attributes ||= {}
      @_attributes.keys
    end

    def value_from_result(result)
      @domain_class.new.tap do |value|
        attributes.each do |name|
          value.public_send("#{name}=", result.public_send(name))
        end
      end
    end
  end
end
