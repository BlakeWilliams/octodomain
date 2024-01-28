# frozen_string_literal: true

module OctoDomain
  # LocalTransport calls methods on the domain object directly in-process.
  class LocalTransport < BaseTransport
    def call(message, *args, **kwargs)
      result = domain.send(message, *args, **kwargs)
      domain.serialize(message, result)
    end
  end
end
