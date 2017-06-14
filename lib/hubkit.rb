require 'active_support/core_ext/module'
require 'active_support/core_ext/object'
require 'active_support/json'
require 'active_support/time'

require 'github_api'
require 'hubkit/configuration'
require 'hubkit/chainable_collection'
require 'hubkit/paginator'
require 'hubkit/cooldowner'
require 'hubkit/event_collection'
require 'hubkit/event_paginator'
require 'hubkit/issue_collection'
require 'hubkit/issue_paginator'
require 'hubkit/issue'
require 'hubkit/logger'
require 'hubkit/repo_collection'
require 'hubkit/repo_paginator'
require 'hubkit/repo'
require 'hubkit/version'

# Main module of the hubkit library. This is generally not used directly, but
# through a subclass such as Hubkit::IssueCollection, Hubkit::EventCollection,
# Hubkit::Repo, etc.
module Hubkit
  class << self
    # Return the Github client used by the library
    # @return [Github::Client] the github API client
    def client
      Configuration.client
    end
  end
end
