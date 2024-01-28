# frozen_string_literal: true

RSpec.describe OctoDomain do
  it "has a version number" do
    expect(OctoDomain::VERSION).not_to be nil
  end

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
      ::Person.create({ name: name, age: age, addresses: addresses })
    end

    def get_person(name)
      ::Person.find_by_name(name)
    end
  end

  describe OctoDomain::Base do
    it "can return domain objects" do
      my_domain_client = MyDomain.client_for(:app)
      my_domain_client.create_person("John", 30, ["123 Main St", "456 Main St"])
      person = my_domain_client.get_person("John")

      expect(person.name).to eq("John")
      expect(person.age).to eq(30)
      expect(person.addresses).to eq(["123 Main St", "456 Main St"])
    end
  end
end
