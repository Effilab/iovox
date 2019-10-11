# frozen_string_literal: true

module Iovox
  module StringInflector
    module_function

    def snake_case(str)
      str = str.dup
      str.gsub!(/([A-Z])/, '_\1')
      str.sub!(/^_/, "")
      str.downcase!
      str
    end

    def camel_case(str)
      str = str.dup
      str.sub!(/^[a-z\d]*/) { $&.capitalize }
      str.gsub!(/_([a-z\d]*)/) { Regexp.last_match(1).capitalize }
      str
    end
  end
end
