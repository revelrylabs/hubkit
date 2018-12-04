# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hubkit/version'

Gem::Specification.new do |spec|
  spec.name          = "hubkit"
  spec.version       = Hubkit::VERSION
  spec.authors       = ["Robert Prehn", "Revelry Labs"]
  spec.email         = ["robert@revelry.co", "support@revelry.co"]
  spec.licenses    = ['MIT']

  spec.summary       = "Higher level abstractions for querying the github API"
  spec.description   = <<-DESC
    Hubkit provides methods for querying the github API at a higher level than
    making individual API calls. Think of it like an ORM for the github API.
  DESC

  spec.homepage      = "https://github.com/revelrylabs/hubkit"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'github_api', '~> 0.16.0'
  spec.add_dependency 'activesupport', '>= 4', '< 6'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coveralls", "= 0.8.13"
end
