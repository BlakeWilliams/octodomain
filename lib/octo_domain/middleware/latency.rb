# frozen_string_literal: true

require "active_support"

module OctoDomain
  module Middleware
    # Latency is a middleware that adds latency to a domain method. This is
    # useful for testing how migrating a domain method to an RPC call will
    # affect the application.
    class Latency
      def initialize(domain, options = {})
        @domain = domain
        @sleep = options[:ms] || 45
      end

      def call(message_name)
        sleep(@sleep / 1000.0)
      end
    end
  end
end
