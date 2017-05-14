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

module Hubkit
  class << self
    def client
      Configuration.client
    end
  end
end
