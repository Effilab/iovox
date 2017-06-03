# frozen_string_literal: true

require 'iovox/client'

RSpec.describe Iovox::Client do
  describe 'configuration' do
    def conn_middlewares(conn)
      conn.builder.handlers
    end

    context 'when :read_only is true' do
      let(:client) { described_class.new(read_only: true) }

      it 'uses a read-only connection' do
        expect(conn_middlewares(client.conn)).to include(Iovox::Middleware::ReadOnly)
      end
    end

    context 'when :read_only is falsy' do
      let(:client) { described_class.new(read_only: nil) }

      it 'uses a regular connection' do
        expect(conn_middlewares(client.conn)).not_to include(Iovox::Middleware::ReadOnly)
      end
    end
  end
end
