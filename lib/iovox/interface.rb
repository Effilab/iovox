# frozen_string_literal: true

module Iovox
  class Interface
    class << self
      def client
        @client || default_client
      end

      attr_writer :client

      def registry
        @registry || default_registry
      end

      def default_client
        Interface.instance_variable_get(:@client)
      end

      def default_registry
        Interface.instance_variable_get(:@registry)
      end
    end

    def initialize(client = nil, registry = nil)
      @client = client if client
      @registry = registry if registry
    end

    def client
      @client || self.class.client
    end

    attr_writer :client

    def registry
      @registry || self.class.registry
    end

    attr_writer :registry
  end
end
