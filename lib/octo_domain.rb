# frozen_string_literal: true

require_relative "octo_domain/version"
require_relative "octo_domain/base"
require_relative "octo_domain/client"
require_relative "octo_domain/value_mapper"
require_relative "octo_domain/base_transport"
require_relative "octo_domain/local_transport"
require_relative "octo_domain/message"

module OctoDomain
  class Error < StandardError; end
end
