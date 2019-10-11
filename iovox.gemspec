# frozen_string_literal: true

require_relative "./lib/iovox/version"

Gem::Specification.new do |spec|
  spec.name     = "iovox"
  spec.version  = Iovox::VERSION
  spec.authors  = ["Effilab"]
  spec.summary  = "IOVOX"

  spec.metadata["allowed_push_host"] = ""

  spec.files = Dir["{config,lib}/**/*", "VERSION", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "socksify"

  spec.add_runtime_dependency "faraday", ">= 0.11"
  spec.add_runtime_dependency "faraday_middleware", ">= 0.11"
  spec.add_runtime_dependency "gyoku"
  spec.add_runtime_dependency "multi_xml"
  spec.add_runtime_dependency "rack"
end
