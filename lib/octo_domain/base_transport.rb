# frozen_string_literal: true

module OctoDomain
  # LocalTransport calls methods on the domain object directly in-process.
  class BaseTransport
    attr_accessor :domain
  end
end
