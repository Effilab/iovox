# frozen_string_literal: true

require 'forwardable'
require 'faraday'
require 'iovox/client' unless defined?(Iovox::Client)

class Iovox::Client::Response
  extend Forwardable

  attr_reader :response

  def initialize(response)
    @response = response
  end

  def_delegators :response, *Faraday::Response.public_instance_methods(false)

  def result
    body.fetch('response').fetch('results')&.fetch('result')
  end
end
