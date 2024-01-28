# frozen_string_literal: true

require "active_support"

module OctoDomain
  # Base is the base class for all domain objects, which expose domain behavior
  # to the application layer.
  class Base
    def self.inherited(subclass)
      @_subclasses ||= []
      @_subclasses << subclass
      subclass.instance_variable_set(:@_objects, @_objects)
      subclass.instance_variable_set(:@_messages, @_messages)
      subclass.instance_variable_set(:@_transport, @_transport)
    end

    def self.object(name, &block)
      domain_class = Class.new
      const_set(name.to_s.split("_").map(&:capitalize).join, domain_class)

      @_objects ||= {}
      @_objects[name.to_sym] = DomainObject.new(name, domain_class)
      @_objects[name.to_sym].instance_exec(&block)
    end

    def self.objects
      @_objects ||= {}
    end

    def self.validate
      @_subclasses.each do |subclass|
        subclass.messages.each do |_name, message|
          raise ArgumentError.new("#{self.class.name} does not respond to #{name}") unless instance_methods.include?(message.name.to_sym)
          raise ArgumentError.new("#{self.class.name} does not respond have a #{message.serialize_with} object") unless instance_methods.include?(message.name.to_sym)
        end
      end
    end

    def self.message(name, serialize_with: nil)
      @_messages ||= {}
      @_messages[name.to_sym] = Message.new(name, serialize_with: serialize_with)
    end

    def self.messages
      @_messages ||= {}
    end

    def self.use_transport(transport, options = {})
      @_transport = transport.new(self, options)
    end

    def self.transport
      @_transport ||= LocalTransport.new
    end

    def self.serialize(message, result)
      domain_object = objects[messages[message].serialize_with]
      domain_object&.value_from_result(result)
    end

    # Creates a new instance of the domain which acts as the client to the
    # domain itself. It's passed a client_name which is used to identify the
    # caller to the domain.
    def self.client_for(client_name)
      Client.new(self, client_name)
    end
  end
end
