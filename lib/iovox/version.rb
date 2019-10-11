# frozen_string_literal: true

module Iovox
  VERSION = File.read(
    File.expand_path(File.join("..", "..", "VERSION"), File.dirname(__FILE__))
  ).strip
end
