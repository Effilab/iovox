# frozen_string_literal: true

require 'rack/utils'

module Iovox
  module Middleware
    class Request
      USERNAME_HEADER = 'username'
      SECURE_KEY_HEADER = 'secureKey'
      VERSION_PARAM = 'v'
      OUTPUT_PARAM = 'output'

      attr_reader :options

      def initialize(app, options)
        @app = app
        @options = options
      end

      def call(env)
        ensure_presence_of_headers(env)
        ensure_presence_of_params(env)

        @app.call(env)
      end

      def ensure_presence_of_headers(env)
        env[:request_headers][USERNAME_HEADER] ||= options.fetch(:username)
        env[:request_headers][SECURE_KEY_HEADER] ||= options.fetch(:secure_key)
      end

      def ensure_presence_of_params(env)
        return unless options.key?(:version) || options.key?(:output)

        url = env[:url]

        query_params = Rack::Utils.parse_query(url.query)

        query_params[VERSION_PARAM] ||= options[:version] if options.key?(:version)
        query_params[OUTPUT_PARAM] ||= options[:output] if options.key?(:output)

        url.query = Rack::Utils.build_query(query_params)
      end
    end
  end
end
