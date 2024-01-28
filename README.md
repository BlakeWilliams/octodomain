# OctoDomain

OctoDomain is a Ruby gem that abstracts data models and allows for the easy and safe creation of domain objects when an application becomes sufficiently complex to warrant them.

Benefits:

- Creating domain objects and mapping them to data models is easy
- Domains are easy to test
- Clients can be created to attribute load to specific dependencies
- Extensible with solid defaults. Pass a custom transport to use a different messaging system e.g. JSON.
- Ensures domain arguments are primitives that could be serialized if the domain is extracted.

## Installation

Install the gem and add to the application's Gemfile by executing:

```
$ bundle add octodomain
```

## Usage

OctoDomain allows you to expose your data access in the form of domain objects that are accessed by a client.

For example, a user domain may expose methods to find and create users like the following:

```ruby
class UserDomain < OctoDomain::Base
  # Creates a MyDomain::User value object that can be used to map the result of
  # domain methods to a value object
  value :user do
    attribute :id
    attribute :email
    attribute :display_name
  end

  # message exposes a domain method that can be called by a client
  message :create_user # returns nil, because there is no serializer passed
  message :get_user, serialize_with: :user # maps the returned user model object to the `user` value object defined above automatically

  private

  # Implements the `create_user` message behavior exposed by the message above
  def create_user(name, age, addresses)
   OctoDomain::BaseTest::Person.create({name: name, age: age, addresses: addresses})
   nil
  end

  # Implements the `get_user` message behavior
  def find(id)
   OctoDomain::BaseTest::Person.find(id)
  end
end
```

Then to interact with the domain, you would create a client:

```ruby
# Optionally specify a transport to use. e.g. use LocalTransport for method calls, or implement JSONTransport for JSON over HTTP
user_domain = UserDomain.client_for("auth_domain", transport: OctoDomain::LocalTransport.new)

user_domain.create_person("Fox Mulder", 30, ["123 Main St"])
user = user_domain.get_person(31) # returns a UserDomain::User value object
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.
