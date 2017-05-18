# frozen_string_literal: true

ENV['IOVOX_URL']        ||= ENV.fetch('DEV_IOVOX_URL')
ENV['IOVOX_USERNAME']   ||= ENV.fetch('DEV_IOVOX_USERNAME')
ENV['IOVOX_SECURE_KEY'] ||= ENV.fetch('DEV_IOVOX_SECURE_KEY')

require 'logger'
require 'iovox/client'

client_config = {}
client_config[:logger] = Logger.new('log/test.log')

if ENV['TEST_PROXY'] == '1'
  client_config[:socks_proxy] = {
    server: ENV.fetch('DEV_LOCAL_PROXY_SERVER'),
    port:   ENV.fetch('DEV_LOCAL_PROXY_PORT'),
  }
end

Iovox::Client.configuration.merge!(client_config)
