# frozen_string_literal: true

require 'pathname'

module Iovox
  class << self
    attr_reader :root
  end

  @root = Pathname.new(File.expand_path(File.join('..', '..'), __FILE__))
end
