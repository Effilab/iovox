# frozen_string_literal: true

require "yaml"
require "faraday"
require "faraday_middleware"

require_relative "../iovox"
require_relative "string_inflector"
require_relative "middleware/request"
require_relative "middleware/xml_request"
require_relative "middleware/encoder"
require_relative "middleware/read_only"
require_relative "middleware/raise_error"
require_relative "logger"

module Iovox
  class Client
    require_relative "client/response"

    API_VERSION = "3"
    API_INTERFACES = YAML.load_file(Iovox.root.join("config", "interfaces.yml"))

    class << self
      def configuration
        @config_mutex.synchronize do
          @configuration ||= default_configuration
        end
      end

      def default_configuration
        {
          url: ENV.fetch("IOVOX_URL", "https://api.iovox.com:444"),
          credentials: {
            username: ENV.fetch("IOVOX_USERNAME"),
            secure_key: ENV.fetch("IOVOX_SECURE_KEY")
          },
          socks_proxy: nil,
          read_only: false,
          logger: nil
        }
      end

      private

      def load_ivars
        @config_mutex = Mutex.new
        @configuration = nil
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

    def establish_connection(config) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      url = config.fetch(:url).to_s
      iovox_request_opts = config.fetch(:credentials).merge(output: "XML", version: API_VERSION)

      if config[:socks_proxy]
        require_relative "middleware/net_http_socks_adapter"

        socks_server, socks_port = config[:socks_proxy].values_at(:server, :port)
      end

      Faraday.new(url: url) do |conn|
        conn.use Middleware::ReadOnly if read_only?
        conn.use Middleware::Request, iovox_request_opts
        conn.use Middleware::XmlRequest
        conn.use Middleware::RaiseError
        conn.response :xml, content_type: /\bxml$/

        if config[:logger]
          conn.response :logger, logger, bodies: true do |middleware|
            middleware.filter(/(secureKey:)(.*)/, '\1 [FILTERED]')
          end
        end

        conn.use Middleware::Encoder

        if socks_server && socks_port
          conn.use(
            Middleware::NetHTTPSOCKSAdapter, socks_server: socks_server, socks_port: socks_port
          )
        else
          conn.adapter Faraday.default_adapter
        end
      end
    end

    API_INTERFACES.each do |iovox_method_name, config|
      definition_params = {
        method_name: StringInflector.snake_case(iovox_method_name),
        http_method: config["type"].upcase,
        faraday_method_name: config["type"].downcase,
        iovox_method_name: iovox_method_name,
        iovox_interface_name: config["interface"]
      }

      definition = format(<<~RUBY, definition_params)
        def %<method_name>s(query: nil, payload: nil, q: nil, p: nil)
          query ||= q
          payload ||= p

          response = conn.%<faraday_method_name>s('%<iovox_interface_name>s') do |req|
            req.params[:method] = '%<iovox_method_name>s'

            if query.is_a?(Hash)
              query.each { |key, value| req.params[key] = value }
            end

            req.body = payload if payload

            yield(req) if block_given?
          end

          Response.new(response)
        end
      RUBY

      class_eval(definition, __FILE__, __LINE__)
    end

    private

    def default_logger
      Logger.new(STDOUT)
    end
  end
end
