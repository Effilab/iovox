# frozen_string_literal: true

module Iovox
  class Interface
    module RegistryOwner
      def registry
        (defined?(@registry) && @registry) || default_registry
      end

      attr_writer :registry

      def client
        registry&.client
      end
    end

    class << self
      include RegistryOwner

      private

      def default_registry
        superclass.respond_to?(:registry) ? superclass.registry : nil
      end
    end

    include RegistryOwner

    # TODO: when initializing a interface without providing a registry, initialize a dedicated
    # registry and do not use the one from the class ?
    def initialize(registry = nil)
      @registry = registry
    end

    private

    def default_registry
      self.class.registry
    end

    def array_wrap(value)
      case value
      when Array
        value
      when nil
        []
      else
        [value]
      end
    end
  end
end
