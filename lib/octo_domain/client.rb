# frozen_string_literal: true

module OctoDomain
  class Client
    def initialize(domain, client_name)
      @domain = domain
      @client_name = client_name

      # Create public methods for each message in the domain
      @domain.messages.each do |_name, message|
        define_singleton_method(message.name) do |*args|
          raw_result = @domain.transport.call(message.name, args)
        end
      end
    end

    def serialize(message, value)
      domain_object = @domain.objects[message.serialize_with]
      domain_object.value_from_result(value) if !domain_object.nil?
    end
  end
end
