require_relative './lib/iovox/version'

Gem::Specification.new do |spec|
  spec.name     = 'iovox'
  spec.version  = Iovox::VERSION
  spec.authors  = ['Erwan Thomas']
  spec.email    = ['erwan@effilab.com']
  spec.summary  = 'IOVOX'

  spec.metadata['allowed_push_host'] = ''

  spec.files = Dir['{config,lib}/**/*', 'VERSION', 'README.md']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'awesome_print', '~> 1.7'
  spec.add_development_dependency 'byebug', '~> 9.0'
  spec.add_development_dependency 'faker', '~> 1.7'

  spec.add_runtime_dependency 'rack', '~> 2.0'
  spec.add_runtime_dependency 'faraday', '~> 0.11'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.11'
  spec.add_runtime_dependency 'multi_xml', '~> 0.6'
  spec.add_runtime_dependency 'nokogiri', '~> 1.7'
  spec.add_runtime_dependency 'gyoku', '~> 1.3'
end
