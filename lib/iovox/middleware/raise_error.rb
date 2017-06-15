# frozen_string_literal: true

module Iovox
  module Middleware
    class ClientError < Faraday::ClientError
      def to_s
        original = super
        extra = api_message

        if api_message
          "#{original} (#{extra})"
        else
          original
        end
      end

      def api_message
        unwrap_api_message(response)
      end

      private

      def unwrap_api_message(response)
        return unless response.respond_to?(:dig)

        response.dig(:body, 'errors', 'error', '__content__')
      end
    end

    class RaiseError < Faraday::Response::RaiseError
      def on_complete(env)
        case env[:status]
        when 404, 407
          super(env)
        when Faraday::Response::RaiseError::ClientErrorStatuses
          raise Iovox::Middleware::ClientError, response_values(env)
        end
      end
    end
  end
end
