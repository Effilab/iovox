# frozen_string_literal: true

module Iovox
  class HashStruct < Struct
    def initialize(params = nil)
      super()

      merge!(params)
    end

    def merge(params)
      dup.tap do |hash_struct|
        hash_struct.merge!(params)
      end
    end

    def merge!(params)
      return unless params

      params.each_pair do |key, value|
        writer = "#{key}="
        public_send(writer, value) if respond_to?(writer)
      end
    end
  end

  class Entity < HashStruct
    class << self
      def from_params(params)
        new(params)
      end

      private

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

    def to_params
      to_h
    end
  end
end
