# frozen_string_literal: true

described_class = "Iovox::Middleware::NetHTTPSOCKSAdapter"

RSpec.describe described_class, order: :defined do # rubocop:disable RSpec/DescribeClass
  describe "optional dependency" do
    def without_load_path(path_regex)
      library_path_index = $LOAD_PATH.find_index { |path| path =~ path_regex }
      return yield unless library_path_index

      library_path = $LOAD_PATH[library_path_index]

      $LOAD_PATH.delete_at(library_path_index)
      yield
      $LOAD_PATH.insert(library_path_index + 1, library_path)
    end

    before do
      if defined?(Iovox::Middleware::NetHTTPSOCKSAdapter)
        skip("library has already been loaded, skipping not applicable example")
      end
    end

    it "is not required by default" do
      require "iovox/client"

      expect(defined?(Iovox::Middleware::NetHTTPSOCKSAdapter)).to be_nil
    end

    context "when it is required with an invalid LOAD_PATH" do
      it "explains the resulting LoadError" do
        without_load_path(/socksify/) do
          expect do
            require "iovox/middleware/net_http_socks_adapter"
          end.to raise_error(LoadError, /socksify.*Gemfile/)
        end
      end
    end
  end

  describe "Faraday adapter" do
    before(:context) do
      require "iovox/middleware/net_http_socks_adapter"
    end

    let(:app) { double }
    let(:proxy_server) { "0.0.0.0" }
    let(:proxy_port) { "9999" }

    let(:adapter) do
      Iovox::Middleware::NetHTTPSOCKSAdapter.new(
        app, proxy_server: proxy_server, proxy_port: proxy_port
      )
    end

    let(:env) do
      { url: URI("http://foo.bar") }
    end

    it "uses a socksify version of Net::HTTP" do
      http = adapter.net_http_connection(env)

      http.socks_server = proxy_server
      http.socks_port = proxy_port

      expect(http.address).to have_attributes(
        peer_host: env[:url].host,
        socks_server: proxy_server,
        socks_port: proxy_port
      )
    end
  end
end
