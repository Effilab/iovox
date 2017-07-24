# frozen_string_literal: true

require 'faraday'

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

        errors = response.dig(:body, 'errors', 'error')

        if errors.is_a?(Array)
          errors.map { |error| error['__content__'] }.join(', ')
        else
          errors['__content__']
        end
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
