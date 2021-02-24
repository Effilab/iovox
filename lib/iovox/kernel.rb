# frozen_string_literal: true

module Iovox
  module Kernel
    def self.require(name, verbose: $VERBOSE)
      old_verbose = $VERBOSE
      $VERBOSE = verbose
      super(name)
    ensure
      $VERBOSE = old_verbose
    end
  end
end
