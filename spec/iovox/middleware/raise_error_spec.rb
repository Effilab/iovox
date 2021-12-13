# frozen_string_literal: true

require "iovox/middleware/raise_error"

RSpec.describe Iovox::Middleware::RaiseError do
  subject(:middleware) { described_class.new(app) }

  let(:app) do
    instance_double(Proc, "app")
  end

  let(:env) do
    instance_double(Faraday::Env, "env", env_data)
  end

  let(:env_data) do
    {
      status: 400,
      response_headers: a_kind_of(Hash),
      body: {
        "errors" => {
          "error" => error
        }
      },
      method: a_kind_of(String),
      url: double(path: a_kind_of(String), query: a_kind_of(String)),
      request_headers: a_kind_of(Hash),
      request_body: a_kind_of(String),
      params_encoder: double(decode: a_kind_of(String)),
      params: a_kind_of(Hash)
    }
  end

  let(:response) do
    instance_double(Faraday::Response, "response")
  end

  before do
    allow(app).to receive(:call).with(env).and_return(response)
    allow(env).to receive(:[]) { |key| env_data.fetch(key) }
    allow(response).to receive(:on_complete).and_yield(env)
  end

  context "when there is a single error" do
    let(:error) do
      {"status" => "400", "__content__" => "foo"}
    end

    it "handles the error" do
      expect do
        middleware.call(env)
      end.to raise_error(Iovox::Middleware::ClientError, /foo/)
    end
  end

  context "when there are several errors" do
    let(:error) do
      [
        {"status" => "400", "__content__" => "foo"},
        {"status" => "400", "__content__" => "bar"}
      ]
    end

    it "handles the errors" do
      expect do
        middleware.call(env)
      end.to raise_error(Iovox::Middleware::ClientError, /foo, bar/)
    end
  end
end
