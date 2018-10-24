require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

require 'rspec/collection_matchers'
require 'bundler/setup'
require 'hubkit'
require 'webmock/rspec'
require 'dotenv'
require 'vcr'
require 'byebug'

VCR.configure do |c|
  c.default_cassette_options = { record: :once, erb: true }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<GITHUB_TOKEN>') { ENV['GITHUB_TOKEN'] }
end

Dotenv.load

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include WebMock::API

  config.before(:suite) do
    Hubkit::Configuration.configure do |gh_config|
      gh_config.oauth_token = ENV['GITHUB_TOKEN']
      gh_config.default_org = ENV['DEFAULT_ORG']
    end
  end

  config.before(:each) do
    WebMock.reset!
  end

  config.after(:each) do
    WebMock.reset!
  end
end
