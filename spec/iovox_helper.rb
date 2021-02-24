# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"
require "byebug"
require "iovox/kernel"
Iovox::Kernel.require "awesome_print", verbose: false

ENV["IOVOX_URL"]        ||= ENV.fetch("DEV_IOVOX_URL")
ENV["IOVOX_USERNAME"]   ||= ENV.fetch("DEV_IOVOX_USERNAME")
ENV["IOVOX_SECURE_KEY"] ||= ENV.fetch("DEV_IOVOX_SECURE_KEY")
