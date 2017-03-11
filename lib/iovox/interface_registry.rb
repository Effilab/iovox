# frozen_string_literal: true

require 'iovox/all'

class Iovox::InterfaceRegistry
  attr_reader :client

  def initialize(client)
    @client = client
    @mutex = Mutex.new
    @map = {}
  end

  def [](key)
    key = key.to_s

    @mutex.synchronize do
      @map.fetch(key) do
        @map[key] = send(key)
      end
    end
  end

  def []=(key, value)
    key = key.to_s

    @mutex.synchronize do
      @map[key] = value
    end
  end

  private

  def node
    Iovox::NodeInterface.new(client, self)
  end

  def link
    Iovox::LinkInterface.new(client, self)
  end

  def node_full
    Iovox::NodeFullInterface.new(client, self)
  end

  def call_rule_template
    Iovox::CallRuleTemplateInterface.new(client, self)
  end
end

