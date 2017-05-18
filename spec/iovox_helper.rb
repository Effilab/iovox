# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'byebug'
require 'iovox/kernel'
Iovox::Kernel.require 'awesome_print', verbose: false

require_relative 'support/client'
require_relative 'support/sandbox_proxy'
