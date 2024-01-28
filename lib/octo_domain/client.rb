# frozen_string_literal: true

module OctoDomain
  class Client
    VALID_ARGUMENT_TYPES = Set.new([String, Integer, Float, TrueClass, FalseClass, NilClass]).freeze

    def initialize(messages, transport, middlewares, client_name)
      @messages = messages
      @transport = transport
      @middlewares = middlewares
      @client_name = client_name
    end

    def method_missing(method_name, *args, **kwargs)
      message_to_call = messages[method_name.to_sym]
      return super unless message_to_call

      validate_arguments(args)
      validate_arguments(kwargs)

      middlewares.each do |middleware|
        middleware.call(message_to_call.name)
      end

      transport.call(message_to_call.name, *args, **kwargs)
    end

    def respond_to_missing?(method_name, include_private = false)
      messages.key?(method_name.to_sym) || super
    end

    private

    attr_reader :domain, :messages, :middlewares, :transport

    # Ensures each argument is a primitive and not an object. e.g. Strings,
    # Integers, etc are fine. Models are not.
    def validate_arguments(args)
      args.each do |arg|
        if arg.is_a?(Array)
          validate_arguments(arg)
        elsif arg.is_a?(Hash)
          validate_arguments(arg.values)
        else
          raise ArgumentError.new("Argument #{arg} is not a primitive") unless VALID_ARGUMENT_TYPES.include?(arg.class)
        end
      end
    end
  end
end
