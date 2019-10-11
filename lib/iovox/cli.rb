# frozen_string_literal: true

require "optparse"

module Iovox
  module Cli
    class Parser
      attr_reader :optparser

      def initialize(&block)
        @optparser = OptionParser.new(&block)
      end

      def call(argv = ARGV)
        begin
          optparser.order!(argv)
        rescue OptionParser::InvalidOption => e
          argv.unshift(*e.args)
        end

        argv
      end
    end
  end
end

options = {
  proxy: false,
  target: :dev
}

Iovox::Cli::Parser.new do |opts|
  opts.on("--[no-]proxy", "Proxy TCP sockets, default: #{options[:proxy]}") do |value|
    options[:proxy] = value
  end

  opts.on("--target=NAME", "Target name (dev/prod), default: #{options[:target]}") do |value|
    case value
    when "dev", "prod"
      options[:target] = value.to_sym
    else
      raise ArgumentError, "Unknown value for --target argument"
    end
  end
end.call

case options[:target]
when :prod
  ENV["IOVOX_URL"]        ||= ENV.fetch("PROD_IOVOX_URL")
  ENV["IOVOX_USERNAME"]   ||= ENV.fetch("PROD_IOVOX_USERNAME")
  ENV["IOVOX_SECURE_KEY"] ||= ENV.fetch("PROD_IOVOX_SECURE_KEY")
else
  ENV["IOVOX_URL"]        ||= ENV.fetch("DEV_IOVOX_URL")
  ENV["IOVOX_USERNAME"]   ||= ENV.fetch("DEV_IOVOX_USERNAME")
  ENV["IOVOX_SECURE_KEY"] ||= ENV.fetch("DEV_IOVOX_SECURE_KEY")
end

if options[:proxy]
  case options[:target]
  when :prod
    ENV["LOCAL_PROXY_SERVER"] ||= ENV["PROD_LOCAL_PROXY_SERVER"]
    ENV["LOCAL_PROXY_PORT"] ||= ENV["PROD_LOCAL_PROXY_PORT"]
  else
    ENV["LOCAL_PROXY_SERVER"] ||= ENV["DEV_LOCAL_PROXY_SERVER"]
    ENV["LOCAL_PROXY_PORT"] ||= ENV["DEV_LOCAL_PROXY_PORT"]
  end
end

require "iovox/client"

Iovox::Client.configuration[:logger] = Iovox::Logger.new(
  File.join("log", "#{options[:target]}.log")
)

if options[:proxy]
  Iovox::Client.configuration[:socks_proxy] = {
    server: ENV["LOCAL_PROXY_SERVER"],
    port: ENV["LOCAL_PROXY_PORT"]
  }
end

Iovox::Client.configuration[:read_only] = true if options[:target] == :prod
