# frozen_string_literal: true

module Iovox
  module Middleware
    class ReadOnly
      ReadOnlyError = Class.new(StandardError)

      def initialize(app)
        @app = app
      end

      def call(env)
        http_method = http_method(env)

        unless allowed?(http_method)
          raise ReadOnlyError, "#{http_method.to_s.upcase} requests are not allowed"
        end

        @app.call(env)
      end

      private

      def http_method(env)
        env[:method]
      end

      def allowed?(http_method)
        case http_method
        when :get, :head
          true
        else
          false
        end
      end
    end
  end
end
