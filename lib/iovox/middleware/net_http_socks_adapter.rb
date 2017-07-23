# frozen_string_literal: true

require 'net/http'
require 'faraday/adapter/net_http'

begin
  require 'socksify'
rescue LoadError
  raise LoadError, 'LoadError: cannot load such file -- socksify. ' \
                   'Add the "socksify" gem to your Gemfile to continue ' \
                   'using Iovox::Middleware::NetHTTPSOCKSAdapter.'
end

module Iovox
  module Middleware
    class NetHTTPSOCKS < Net::HTTP
      attr_accessor :socks_server, :socks_port

      def address
        TCPSocket::SOCKSConnectionPeerAddress.new(socks_server, socks_port, @address)
      end
    end

    class NetHTTPSOCKSAdapter < Faraday::Adapter::NetHttp
      attr_reader :socks_server, :socks_port

      def initialize(app, socks_server, socks_port)
        super(app)

        @socks_server = socks_server
        @socks_port = socks_port
      end

      def net_http_connection(env)
        host = env[:url].host
        port = env[:url].port || (env[:url].scheme == 'https' ? 443 : 80)

        NetHTTPSOCKS.new(host, port).tap do |http|
          http.socks_server = socks_server
          http.socks_port = socks_port
        end
      end
    end
  end
end
