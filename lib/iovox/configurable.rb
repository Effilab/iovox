# frozen_string_literal: true

module Iovox
  class Configurable
    def initialize(&block)
      @settings = {}
      @scope = []
      @nested_settings = []
      @callable_settings = []
      instance_eval(&block)
      @settings.freeze
    end

    def setting(name, default_value = nil)
      if block_given?
        write_nested_setting(name, &Proc.new)
      else
        write_setting(name, default_value)
      end
    end

    def call
      out = settings.dup

      nested_settings.each do |nesting|
        parent = nesting.size == 1 ? out : out.dig(*nesting[0..-2])
        setting_key = nesting[-1]

        parent[setting_key] = parent[setting_key].dup
      end

      callable_settings.each do |nesting|
        parent = nesting.size == 1 ? out : out.dig(*nesting[0..-2])
        child = nesting[-1]

        parent[child] = parent[child].call
      end

      out
    end

    private

    attr_reader :settings, :scope, :nested_settings, :callable_settings

    def scoped_settings
      scope.empty? ? settings : settings.dig(*scope)
    end

    def write_setting(name, value)
      callable_settings.push([*scope, name]) if value.respond_to?(:call)

      scoped_settings[name] = value
    end

    def write_nested_setting(name)
      nested_settings.push([*scope, name])

      nested_settings = {}

      scoped_settings[name] = nested_settings

      begin
        scope.push(name)
        yield
      ensure
        scope.pop
        nested_settings.freeze
      end
    end

    module Mixin
      def defaults
        if block_given?
          @configurable = Configurable.new(&Proc.new)
        else
          @configurable.call
        end
      end
    end
  end
end
