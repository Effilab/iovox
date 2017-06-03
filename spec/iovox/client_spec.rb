# frozen_string_literal: true

require 'iovox/client'

RSpec.describe Iovox::Client do
  describe 'configuration' do
    describe 'defaults' do
      subject do
        Class.new(described_class) { load_ivars }
      end

      specify 'are lazy-loaded in a thread-safe way' do
        expect(Iovox::Configuration).to receive(:defaults).once do
          sleep 0.01

          :foo
        end

        call_results = Array.new(2) do
          Thread.new { subject.configuration }
        end.map(&:value)

        expect(call_results).to all(eq(:foo))
      end
    end

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
