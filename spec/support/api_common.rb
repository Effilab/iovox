# frozen_string_literal: true

require 'iovox/client'

client_config = {}
client_config[:logger] = Iovox::Logger.new('log/test.log')

if ENV['TEST_PROXY'] == '1'
  client_config[:socks_proxy] = {
    server: ENV.fetch('DEV_LOCAL_PROXY_SERVER'),
    port:   ENV.fetch('DEV_LOCAL_PROXY_PORT'),
  }
end

Iovox::Client.configuration.merge!(client_config)
