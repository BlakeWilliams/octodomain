# frozen_string_literal: true

require "active_support"

module OctoDomain
  # Base is the base class for all domain objects, which expose domain behavior
  # to the application layer.
  class Base
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
      subclass.instance_variable_set(:@objects, @objects)
      subclass.instance_variable_set(:@messages, @messages)
      subclass.instance_variable_set(:@transport, @transport)
    end

    # Creates a new instance of the domain which acts as the client to the
    # domain itself. It's passed a client_name which is used to identify the
    # caller to the domain.
    def self.client_for(client_name, transport: LocalTransport.new)
      transport.domain = self
      Client.new(messages, transport, middlewares, client_name)
    end

    def self.value(name, &block)
      domain_class = Class.new(Value)
      const_set(name.to_s.split("_").map(&:capitalize).join + "Value", domain_class)

      values[name.to_sym] = ValueMapper.new(name, domain_class)
      values[name.to_sym].instance_exec(&block)
    end

    def self.values
      @values ||= {}
    end

    def self.validate
      subclasses.each do |subclass|
        subclass.messages.each do |_name, message|
          raise ArgumentError.new("#{self.class.name} does not respond to #{name}") unless instance_methods.include?(message.name.to_sym)
          raise ArgumentError.new("#{self.class.name} does not respond have a #{message.serialize_with} object") unless instance_methods.include?(message.name.to_sym)
        end
      end
    end

    def self.message(name, serialize_with: nil)
      messages[name.to_sym] = Message.new(name, serialize_with: serialize_with)
    end

    def self.messages
      @messages ||= {}
    end

    def self.serialize(message, result)
      value_mapper = values[messages[message].serialize_with]
      value_mapper&.serialize(result)
    end

    def self.use(middleware, opts = {})
      middlewares.push(middleware.new(self, opts))
    end

    def self.middlewares
      @middlewares ||= []
    end

    private

    attr_reader :subclasses
  end
end
