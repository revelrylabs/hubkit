Master build status: ![TravisCI Build Status](https://travis-ci.org/revelrylabs/hubkit.svg)

# Hubkit

Hubkit is a high level library for interacting with the github API. It is focused on models and collections,
not individual API operations. If the github_api gem is a raw database connection, Hubkit is an ORM.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hubkit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hubkit

## Usage

### Configuration

Set your configuration with a block like this:

```
Hubkit::Configuration.configure do |c|
  c.oauth_token = ENV['GITHUB_TOKEN']
  c.default_org = ENV['DEFAULT_ORG']
end
```

Hubkit accepts any configuration options that the github_api gem accepts, see: https://github.com/piotrmurach/github

### Using Hubkit in your code

#### Resource models

Hubkit supports Repo, Event, and Issue models which correspond to those resources in the API.

Repo model:

```ruby
repo = Hubkit::Repo.new(org: 'rails', 'rails')
```

Issue model:

```ruby
issue = Hubkit::Repo.new(org: 'rails', repo: 'rails', number: 1)
```

#### Filterable scopes

Hubkit features filterable scopes for resources (such as issues and events).

For example, filtering issues for a repo:

```ruby
repo.issues.closed.opened_between(Time.zone.now - 14.days, Time.zone.now)
```

Or filter events for an issue:

```
issue.events.reverse_chronological.labeled('in progress')
```

Check out [the documentation](http://www.rubydoc.info/github/revelrylabs/hubkit/master)
for the complete current list of built in scopes.

#### Custom scopes

For each chainable collection, Hubkit also implements `select` which returns
a collection which is also chainable. You can use this to implement custom
filters. For example, this would get the closed issues in the "v1.0"
milestone:

```ruby
issues.select do |issue|
  issue['milestone']['title'] == 'v1.0'
end.closed
```

## Roadmap

We have tons of ideas for new Hubkit features. Here are just a couple we hope to add soon:

- Support Github's newer GraphQL API. This will allow Hubkit to do many of its operations faster.
- Add more built-in chainable scopes. You can easily write your own now, but we want to cover the most common operations right out of the box.
- Adding support for the newer Projects and Reviews endpoints of the Github API.

## Contributing

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Bug reports and pull requests are welcome on GitHub at https://github.com/revelrylabs/hubkit. Check out [CONTRIBUTING.md](https://github.com/revelrylabs/hubkit/blob/master/CONTRIBUTING.md) for more info.

Everyone is welcome to participate in the project. We expect contributors to
adhere the Contributor Covenant Code of Conduct (see [CODE_OF_CONDUCT.md](https://github.com/revelrylabs/hubkit/blob/master/CODE_OF_CONDUCT.md)).
