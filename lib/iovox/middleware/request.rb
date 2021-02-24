# frozen_string_literal: true

require "rack/utils"

module Iovox
  module Middleware
    class Request
      USERNAME_HEADER = "username"
      SECURE_KEY_HEADER = "secureKey"
      VERSION_PARAM = "v"
      OUTPUT_PARAM = "output"

      def initialize(app, options)
        @app = app
        @options = options
      end

      def call(env)
        ensure_presence_of_headers(env)
        ensure_presence_of_params(env)

        @app.call(env)
      end

      private

      def change_query(env)
        url = env[:url]
        query_params = Rack::Utils.parse_query(url.query)
        yield query_params
        url.query = Rack::Utils.build_query(query_params)
      end

      def ensure_presence_of_headers(env)
        env[:request_headers][USERNAME_HEADER] ||= @options.fetch(:username)
        env[:request_headers][SECURE_KEY_HEADER] ||= @options.fetch(:secure_key)
      end

      def ensure_presence_of_params(env)
        has_version = @options.key?(:version)
        has_output = @options.key?(:output)
        return unless has_version || has_output

        change_query(env) do |query|
          query[VERSION_PARAM] ||= @options[:version] if has_version
          query[OUTPUT_PARAM] ||= @options[:output] if has_output
        end
      end
    end
  end
end
