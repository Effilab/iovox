# frozen_string_literal: true

require "iovox/client"

RSpec.describe Iovox::Client do
  describe "configuration" do
    let(:client_class) do
      Class.new(described_class) { load_ivars }
    end

    it "is ready for usage by default" do
      allow(ENV).to receive(:fetch).with("IOVOX_URL", any_args).and_return(url = double)
      allow(ENV).to receive(:fetch).with("IOVOX_USERNAME").and_return(username = double)
      allow(ENV).to receive(:fetch).with("IOVOX_SECURE_KEY").and_return(securekey = double)

      expect(client_class.default_configuration).to eq(
        url: url,
        credentials: {
          username: username,
          secure_key: securekey
        },
        logger: nil,
        read_only: false,
        socks_proxy: nil
      )
    end

    it "is lazy-loaded in a thread-safe way" do
      configuration = double

      expect(client_class).to receive(:default_configuration).once do
        sleep 0.01
        configuration
      end

      call_results = Array.new(2) do
        Thread.new { client_class.configuration }
      end.map(&:value)

      expect(call_results).to all(be(configuration))
    end
  end

  def conn_middlewares(conn)
    conn.builder.handlers
  end

  context "when :read_only is true" do
    let(:client) { described_class.new(read_only: true) }

    it "uses a read-only connection" do
      expect(conn_middlewares(client.conn)).to include(Iovox::Middleware::ReadOnly)
    end
  end

  context "when :read_only is falsy" do
    let(:client) { described_class.new(read_only: nil) }

    it "uses a regular connection" do
      expect(conn_middlewares(client.conn)).not_to include(Iovox::Middleware::ReadOnly)
    end
  end

  context "when :logger is truthy" do
    let(:middleware) { Faraday::Response::Logger }
    let(:client) { described_class.new(logger: logger) }

    shared_examples "connection logger" do
      it "logs full interactions" do
        expect(conn_middlewares(client.conn)).to include(middleware)
        expect(middleware).to receive(:new).with(a_value, client.logger, bodies: true)

        client.conn.builder.app
      end
    end

    context "when :logger is true" do
      let(:logger) { true }

      it "uses its default logger" do
        expect(client.logger).to be_a(Logger)
      end

      include_examples "connection logger"
    end

    context "when :logger is a logger" do
      let(:logger) { double }

      it "has the given logger" do
        expect(client.logger).to be(logger)
      end

      include_examples "connection logger"
    end
  end
end
