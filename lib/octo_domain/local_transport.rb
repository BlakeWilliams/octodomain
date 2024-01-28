# frozen_string_literal: true

module OctoDomain
  # LocalTransport calls methods on the domain object directly in-process.
  class LocalTransport < BaseTransport
    def call(message, args)
      result = domain.new.send(message, *args)
      domain.serialize(message, result)
    end
  end
end
