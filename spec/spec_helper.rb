# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'byebug'
require 'awesome_print'

require_relative 'support/client'
require_relative 'support/sandbox_proxy'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
