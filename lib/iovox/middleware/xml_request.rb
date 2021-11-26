# frozen_string_literal: true

require "iovox/kernel"
Iovox::Kernel.require "gyoku", verbose: false

module Iovox
  module Middleware
    class XmlRequest
      CONTENT_TYPE = "Content-Type"
      MIME_TYPE = "application/xml"
      MIME_TYPE_REGEX = %r{^application/(vnd\..+\+)?xml$}.freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        match_request(env) do |payload|
          env.body = serialize_to_xml(payload)
        end

        @app.call(env)
      end

      def match_request(env)
        return unless process_request?(env)

        env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
        yield(env[:body])
      end

      def process_request?(env)
        type = request_type(env)

        env[:body].is_a?(Hash) && (type.empty? || MIME_TYPE_REGEX =~ type)
      end

      def request_type(env)
        type = env[:request_headers][CONTENT_TYPE].to_s
        type = type.split(";", 2).first if type.index(";")
        type
      end

      def serialize_to_xml(payload)
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          #{Gyoku.xml(payload, unwrap: true, key_converter: :none)}
        XML
      end
    end
  end
end
