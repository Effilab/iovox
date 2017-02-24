# frozen_string_literal: true

module Iovox
  module StringInflector
    extend self

    def underscore(str)
      str = str.dup
      str.gsub!(/([A-Z])/, '_\1')
      str.gsub!(/^_/, '')
      str.downcase!
      str
    end
  end
end
