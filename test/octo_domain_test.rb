# frozen_string_literal: true

require "test_helper"

class OctoDomainTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil OctoDomain::VERSION
  end
end
