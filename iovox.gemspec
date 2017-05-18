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

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'socksify'
  spec.add_development_dependency 'dotenv'

  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'faraday', '>= 0.9.2'
  spec.add_runtime_dependency 'faraday_middleware', '>= 0.9.2'
  spec.add_runtime_dependency 'multi_xml'
  spec.add_runtime_dependency 'gyoku'
end
