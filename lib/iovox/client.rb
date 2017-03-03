# frozen_string_literal: true

require 'yaml'
require 'faraday'
require 'faraday_middleware'

require 'iovox'
require 'iovox/string_inflector'
require 'iovox/xml'
require 'iovox/middleware/request'
require 'iovox/middleware/xml_request'
require 'iovox/middleware/logger'

class Iovox::Client
  require 'iovox/client/response'

  API_VERSION = '3'
  API_INTERFACES = YAML.load_file(Iovox.root.join('config', 'interfaces.yml'))

  class << self
    attr_accessor :configuration
  end

  @configuration = {
    url: ENV.fetch('IOVOX_URL', 'https://api.iovox.com:444'),
    credentials: {
      username:   ENV['IOVOX_USERNAME'],
      secure_key: ENV['IOVOX_SECURE_KEY'],
    },
    logger: nil,
    read_only: false,
  }

  attr_reader :conn

  def initialize(config = self.class.configuration)
    @conn = establish_connection(config)
    @read_only = config.fetch(:read_only, false)
  end

  def read_only?
    @read_only
  end

  attr_writer :read_only

  def establish_connection(config)
    url = config.fetch(:url).to_s
    iovox_request_opts = config.fetch(:credentials).merge(output: 'XML', version: API_VERSION)

    Faraday.new(url: url) do |conn|
      conn.use Iovox::Middleware::Request, iovox_request_opts
      conn.use Iovox::Middleware::XmlRequest
      conn.response :xml, :content_type => /\bxml$/
      conn.response :raise_error

      if config[:logger]
        conn.use Iovox::Middleware::Logger, config[:logger], bodies: true do |middleware|
          middleware.filter(/(secureKey:)(.*)/,'\1 [FILTERED]')
        end
      end

      conn.adapter Faraday.default_adapter
    end
  end

  API_INTERFACES.each do |iovox_method_name, config|
    definition_params = {
      method_name: Iovox::StringInflector.underscore(iovox_method_name),
      http_method: config['type'].upcase,
      faraday_method_name: config['type'].downcase,
      iovox_method_name: iovox_method_name,
      iovox_interface_name: config['interface'],
    }

    definition = format(<<~RUBY, definition_params)
      def %{method_name}(query: nil, payload: nil, q: nil, p: nil)
        authorize_http_method(:%{http_method})

        query ||= q
        payload ||= p

        payload = serialize(payload, :%{method_name})

        response = conn.%{faraday_method_name}('%{iovox_interface_name}') do |req|
          req.params[:method] = '%{iovox_method_name}'

          if query.is_a?(Hash)
            query.each { |key, value| req.params[key] = value }
          end

          req.body = payload if payload

          yield(req) if block_given?
        end

        Iovox::Client::Response.new(response)
      end
    RUBY

    class_eval(definition, __FILE__, __LINE__)
  end

  private

  def http_method_safe?(http_method)
    return true unless read_only?

    http_method == :GET
  end

  def authorize_http_method(http_method)
    return if http_method_safe?(http_method)

    raise "Rejected unsafe HTTP #{http_method} method"
  end

  def serialize(payload, method_name)
    return payload unless (
      payload.is_a?(Hash) && Iovox::XML.respond_to?(method_name)
    )

    Iovox::XML.public_send(method_name, payload)
  end
end
