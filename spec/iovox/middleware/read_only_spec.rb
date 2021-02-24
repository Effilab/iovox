# frozen_string_literal: true

require "iovox/middleware/read_only"

RSpec.describe Iovox::Middleware::ReadOnly do
  let(:app) { double }
  let(:env) { double }

  let(:middleware) { described_class.new(app) }

  shared_context "with HTTP request method" do |http_method|
    let(:http_method) { http_method }

    before do
      allow(env).to receive(:[]).with(:method).and_return(http_method.downcase.to_sym)
    end
  end

  shared_examples "request allowed" do
    it "allows the request" do
      expect(app).to receive(:call).with(env)

      middleware.call(env)
    end
  end

  shared_examples "request rejected" do
    it "rejects the request" do
      expect(app).not_to receive(:call).with(:env)

      expect do
        middleware.call(env)
      end.to raise_error(
        described_class::ReadOnlyError, /#{http_method} requests are not allowed/
      )
    end
  end

  %w[GET HEAD].each do |http_method|
    context "when the request method is #{http_method}" do
      include_context "with HTTP request method", http_method
      include_examples "request allowed"
    end
  end

  %w[POST PUT PATCH DELETE].each do |http_method|
    context "when the request method is #{http_method}" do
      include_context "with HTTP request method", http_method
      include_examples "request rejected"
    end
  end
end
