# frozen_string_literal: true

require 'iovox/interface_registry'

RSpec.describe Iovox::InterfaceRegistry do
  let(:client) { double }

  let(:registry) do
    described_class.new(client)
  end

  it 'is given a client' do
    registry = described_class.new(client)

    expect(registry.client).to be(client)
  end

  it 'may not change its client' do
    expect {
      registry.client = double
    }.to raise_error(NoMethodError)
  end

  it 'memoizes its values' do
    expect(registry[:node]).to eq(registry[:node])
  end

  it 'is thread-safe' do
    expect(Iovox::NodeInterface).to receive(:new).once.and_wrap_original do |m, *args|
      sleep 0.01

      m.call(*args)
    end

    Array.new(2) do
      Thread.new { registry[:node] }
    end.each(&:join)
  end

  describe 'interfaces' do
    it 'provides instances of interfaces' do
      expect(registry[:node]).to be_a(Iovox::NodeInterface)
      expect(registry[:link]).to be_a(Iovox::LinkInterface)
      expect(registry[:call_rule_template]).to be_a(Iovox::CallRuleTemplateInterface)
    end

    it 'shares itself with the instances' do
      expect(registry[:node].registry).to be(registry)
    end
  end
end
