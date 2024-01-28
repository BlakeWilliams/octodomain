# frozen_string_literal: true

require "test_helper"
require "octo_domain/middleware/latency"

class OctoDomain::Middleware::LatencyTest < Minitest::Test
  def test_it_works
    domain = Class.new(OctoDomain::Base) do
      message :greeting
      def greeting
      end

      use OctoDomain::Middleware::Latency, ms: 100
    end

    client = domain.client_for(:app)

    start_time = Time.now
    client.greeting
    end_time = Time.now

    assert_in_delta 0.1, end_time - start_time, 0.01
  end
end
