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

    context 'when :logger is truthy' do
      let(:middleware) { Iovox::Middleware::Logger }
      let(:client) { described_class.new(logger: logger) }

      shared_examples 'connection logger' do
        it 'logs full interactions' do
          expect(conn_middlewares(client.conn)).to include(middleware)
          expect(middleware).to receive(:new).with(a_value, client.logger, bodies: true)

          client.conn.builder.app
        end
      end

      context 'when :logger is true' do
        let(:logger) { true }

        it 'uses its default logger' do
          expect(client.logger).to be_a(Logger)
        end

        include_examples 'connection logger'
      end

      context 'when :logger is a logger' do
        let(:logger) { double('logger') }

        it 'has the given logger' do
          expect(client.logger).to be(logger)
        end

        include_examples 'connection logger'
      end
    end

    context 'when a SOCKS proxy is configured' do
      let(:config) do
        Hash[socks_proxy: { server: '0.0.0.0', port: '8888' }]
      end

      subject(:client) { described_class.new(config) }

      before(:context) { require 'iovox/middleware/net_http_socks_adapter' }

      it 'connects through the proxy' do
        server, port = config[:socks_proxy].values_at(:server, :port)

        # this will serve to interrupt and observe the request cycle
        interrupt = Class.new(StandardError)

        expect(Iovox::Middleware::NetHTTPSOCKS).to receive(:new).and_wrap_original do |m, *args, &block|
          m.call(*args, &block).tap do |handler|
            expect(handler).to receive(:request) do
              expect(handler.socks_server).to eq(server)
              expect(handler.socks_port).to eq(port)

              # mock actual connection, we don't care about what would happen next
              raise(interrupt)
            end
          end
        end

        expect {
          client.conn.get('/')
        }.to raise_error(interrupt)
      end
    end
  end
end
