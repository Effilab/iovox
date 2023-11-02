# frozen_string_literal: true

require "yaml"
require "faraday"
require "faraday/decode_xml"

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

    def initialize(args = {})
      config = self.class.configuration.merge(args)

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
      iovox_request_opts = config.fetch(:credentials).merge(output: "XML", version: API_VERSION)

      # TODO
      Faraday.new(url: url) do |conn|
        conn.use Middleware::ReadOnly if read_only?
        conn.use Middleware::Request, iovox_request_opts
        conn.use Middleware::XmlRequest
        conn.use Middleware::RaiseError
        conn.response :xml

        if config[:logger]
          conn.response :logger, logger, bodies: true do |middleware|
            middleware.filter(/(secureKey:)(.*)/, '\1 [FILTERED]')
          end
        end

        conn.use Middleware::Encoder
        conn.adapter Faraday.default_adapter
      end
    end

    YAML.load_file(
      File.expand_path("../../config/interfaces.yml", __dir__)
    ).each do |iovox_method_name, config|
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
      Logger.new($stdout)
    end
  end
end
