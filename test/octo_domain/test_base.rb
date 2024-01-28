# frozen_string_literal: true

require "test_helper"

class OctoDomain::BaseTest < Minitest::Test
  # Imitate ActiveRecord
  class Person
    def self.create(attrs)
      @_people ||= {}
      @_people[attrs[:name]] = new(attrs[:name], attrs[:age], attrs[:addresses])
    end

    def self.find_by_name(name)
      @_people ||= {}
      @_people[name]
    end

    attr_reader :name, :age, :addresses

    def initialize(name, age, addresses)
      @name = name
      @age = age
      @addresses = addresses
    end
  end

  class MyDomain < OctoDomain::Base
    object :person do
      attribute :name
      attribute :age
      attribute :addresses
    end

    message :create_person
    message :get_person, serialize_with: :person

    use_transport OctoDomain::LocalTransport

    def create_person(name, age, addresses)
      OctoDomain::BaseTest::Person.create({name: name, age: age, addresses: addresses})
    end

    def get_person(name)
      OctoDomain::BaseTest::Person.find_by_name(name)
    end
  end

  def test_returns_domain_objects
    my_domain_client = MyDomain.client_for(:app)
    my_domain_client.create_person("Fox Mulder", 30, ["123 Main St", "456 Main St"])
    person = my_domain_client.get_person("Fox Mulder")

    assert_equal "Fox Mulder", person.name
    assert_equal 30, person.age
    assert_equal ["123 Main St", "456 Main St"], person.addresses
  end

  def test_raises_if_domain_method_does_not_exist
    Class.new(OctoDomain::Base) do
      message :greeting
    end

    assert_raises(ArgumentError) do
      OctoDomain::Base.validate
    end
  end

  def test_raises_if_serializer_object_does_not_exist
    Class.new(OctoDomain::Base) do
      message :greeting, serialize_with: :person
      def greeting
      end
    end

    assert_raises(ArgumentError) do
      OctoDomain::Base.validate
    end
  end

  class MockTransport < OctoDomain::LocalTransport
    def call(message, params)
      @_calls ||= {}
      @_calls[message] ||= []
      @_calls[message] << params
    end

    def calls
      @_calls
    end
  end

  def test_can_use_custom_transports
    mock_domain = Class.new(MyDomain) do
      use_transport MockTransport
    end
    mock_domain_client = mock_domain.client_for(:app)

    mock_domain_client.create_person("Fox Mulder", 30, ["123 Main St", "456 Main St"])

    calls = mock_domain.transport.calls[:create_person]
    assert_equal 1, calls.length
    first_call = calls.first
    assert_equal ["Fox Mulder", 30, ["123 Main St", "456 Main St"]], first_call
  end
end
