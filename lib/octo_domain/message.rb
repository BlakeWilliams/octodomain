# frozen_string_literal: true

module OctoDomain
  class Message
    attr_reader :name, :serialize_with

    def initialize(name, serialize_with: nil)
      @name = name
      @serialize_with = serialize_with
    end

    def serialize(result, domain_object)
      # TODO raise if result is not nil and serialize_with is nil, or vice versa
      if result && serialize_with
        domain_object.serialize(result)
      end
    end
  end
end
