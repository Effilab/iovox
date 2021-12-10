# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "iovox"
  spec.version = File.read(File.expand_path("VERSION", __dir__)).strip
  spec.authors = ["Effilab"]
  spec.summary = "IOVOX"

  spec.metadata["allowed_push_host"] = ""

  spec.files = Dir["{config,lib}/**/*", "VERSION", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "standard", "1.4.0"
  spec.add_development_dependency "socksify"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "faraday", ">= 1", "<2"
  spec.add_runtime_dependency "faraday_middleware", ">= 1", "<2"
  spec.add_runtime_dependency "gyoku"
  spec.add_runtime_dependency "multi_xml"
  spec.add_runtime_dependency "rack"
end
