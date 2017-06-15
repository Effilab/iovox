# frozen_string_literal: true

require 'yaml'
require 'faraday'
require 'faraday_middleware'

require 'iovox'
require 'iovox/configuration'
require 'iovox/string_inflector'
require 'iovox/middleware/request'
require 'iovox/middleware/xml_request'
require 'iovox/middleware/encoder'
require 'iovox/middleware/read_only'
require 'iovox/middleware/raise_error'
require 'iovox/logger'

class Iovox::Client
  require 'iovox/client/response'

  API_VERSION = '3'
  API_INTERFACES = YAML.load_file(Iovox.root.join('config', 'interfaces.yml'))

  class << self
    def configuration
      @configuration || load_configuration
    end

    private

    attr_reader :config_mutex

    def load_ivars
      @config_mutex = Mutex.new
      @configuration = nil
    end

    def load_configuration
      config_mutex.synchronize do
        @configuration ||= Iovox::Configuration.defaults
      end
    end
  end

  load_ivars

  attr_reader :conn, :logger

  def initialize(config = self.class.configuration, **args)
    config = config.merge(args) unless args.empty?

    if config[:logger]
      @logger = config[:logger] == true ? default_logger : config[:logger]
    end

    @read_only = config.fetch(:read_only, false)

    @conn = establish_connection(config)
  end

  def read_only?
    @read_only
  end

  def establish_connection(config)
    url = config.fetch(:url).to_s
    iovox_request_opts = config.fetch(:credentials).merge(output: 'XML', version: API_VERSION)

    if config[:socks_proxy]
      require 'iovox/middleware/net_http_socks_adapter'

      socks_server, socks_port = config[:socks_proxy].values_at(:server, :port)
    end

    Faraday.new(url: url) do |conn|
      conn.use Iovox::Middleware::ReadOnly if read_only?
      conn.use Iovox::Middleware::Request, iovox_request_opts
      conn.use Iovox::Middleware::XmlRequest
      conn.use Iovox::Middleware::RaiseError
      conn.response :xml, :content_type => /\bxml$/

      if config[:logger]
        conn.response :logger, logger, bodies: true do |middleware|
          middleware.filter(/(secureKey:)(.*)/, '\1 [FILTERED]')
        end
      end

      conn.use Iovox::Middleware::Encoder

      if socks_server && socks_port
        conn.use Iovox::Middleware::NetHTTPSOCKSAdapter do |http|
          http.socks_server = socks_server
          http.socks_port = socks_port
        end
      else
        conn.adapter Faraday.default_adapter
      end
    end
  end

  API_INTERFACES.each do |iovox_method_name, config|
    definition_params = {
      method_name: Iovox::StringInflector.snake_case(iovox_method_name),
      http_method: config['type'].upcase,
      faraday_method_name: config['type'].downcase,
      iovox_method_name: iovox_method_name,
      iovox_interface_name: config['interface'],
    }

    definition = format(<<~RUBY, definition_params)
      def %{method_name}(query: nil, payload: nil, q: nil, p: nil)
        query ||= q
        payload ||= p

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

  def default_logger
    Iovox::Logger.new(STDOUT)
  end
end
