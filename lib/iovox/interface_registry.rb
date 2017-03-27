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
      @map[key] ||= interface_for(key)
    end
  end

  private

  def interface_for(entity_name)
    interface_name = "#{Iovox::StringInflector.camel_case(entity_name)}Interface"

    Iovox.const_get(interface_name).new(self)
  end
end

