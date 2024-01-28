# frozen_string_literal: true

require "active_support"

module OctoDomain
  class Value
    def self.from(result, attribute_map:)
      new.tap do |value|
        attribute_map.each do |name, method|
          value.public_send(:"#{name}=", result.public_send(method))
        end
      end
    end
  end
end
