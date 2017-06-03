# frozen_string_literal: true

require 'iovox/configurable'

module Iovox
  class Configuration
    extend Configurable::Mixin

    defaults do
      setting :url, -> { ENV.fetch('IOVOX_URL', 'https://api.iovox.com:444') }

      setting :credentials do
        setting :username, -> { ENV.fetch('IOVOX_USERNAME') }
        setting :secure_key, -> { ENV.fetch('IOVOX_SECURE_KEY') }
      end

      setting :socks_proxy, nil
      setting :read_only, false
      setting :logger, nil
    end
  end
end
