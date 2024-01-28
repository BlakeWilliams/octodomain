# frozen_string_literal: true

module OctoDomain
  # LocalTransport calls methods on the domain object directly in-process.
  class BaseTransport
    def initialize(domain, _opts)
      @domain = domain
    end

    private

    attr_reader :domain
  end
end
