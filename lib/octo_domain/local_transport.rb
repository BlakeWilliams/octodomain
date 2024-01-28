# frozen_string_literal: true

module OctoDomain
  # LocalTransport calls methods on the domain object directly in-process.
  class LocalTransport < BaseTransport
    def initialize(domain, options)
      @domain = domain
    end

    def call(message, args)
      result = domain.new.public_send(message, *args)
      domain.serialize(message, result)
    end
  end
end
