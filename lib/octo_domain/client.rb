# frozen_string_literal: true

module OctoDomain
  class Client
    VALID_ARGUMENT_TYPES = Set.new([String, Integer, Float, TrueClass, FalseClass, NilClass]).freeze

    def initialize(messages, transport, middlewares, client_name)
      @domain = domain
      @client_name = client_name

      # Create public methods for each message in the domain
      messages.each do |_name, message|
        define_singleton_method(message.name) do |*args|
          validate_arguments(args)
          middlewares.each do |middleware|
            middleware.call(message.name, args)
          end

          transport.call(message.name, args)
        end
      end
    end

    private

    attr_reader :domain

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
