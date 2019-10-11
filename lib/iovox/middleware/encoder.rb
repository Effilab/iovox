# frozen_string_literal: true

module Iovox
  module Middleware
    # IOVOX does not include encoding information in the response headers.
    # This middleware assumes and enforces that their API only returns UTF-8-encoded strings.
    #
    # By the way, Net::HTTP does not handle correctly encodings (see
    # https://bugs.ruby-lang.org/issues/2567).
    class Encoder
      def initialize(app)
        @app = app
      end

      def call(request_env)
        @app.call(request_env).on_complete do |response_env|
          response_env[:body].force_encoding("UTF-8")
        end
      end
    end
  end
end
