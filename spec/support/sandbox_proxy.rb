# frozen_string_literal: true

require 'socksify'

module SandboxProxy
  def self.included(base)
    return if ENV['TEST_PROXY'] == '0'

    base.around(:each) do |example|
      Socksify.proxy('0.0.0.0', '9999') do
        example.run
      end
    end
  end
end

RSpec.configure do |config|
  config.include(SandboxProxy, proxy: true)
end
