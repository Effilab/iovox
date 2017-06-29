# frozen_string_literal: true

require 'iovox/configuration'

RSpec.describe Iovox::Configuration do
  it 'provides a set of default values' do
    expect(ENV).to receive(:fetch).with('IOVOX_URL', any_args).and_return(:iovox_url)
    expect(ENV).to receive(:fetch).with('IOVOX_USERNAME').and_return(:iovox_username)
    expect(ENV).to receive(:fetch).with('IOVOX_SECURE_KEY').and_return(:iovox_secure_key)

    expect(described_class.defaults).to eq(
      url: :iovox_url,
      credentials: {
        username: :iovox_username,
        secure_key: :iovox_secure_key,
      },
      logger: nil,
      read_only: false,
      socks_proxy: nil,
    )
  end
end
