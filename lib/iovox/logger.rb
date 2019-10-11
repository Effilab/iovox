# frozen_string_literal: true

require "time"
require "logger"

module Iovox
  class Logger < ::Logger
    def initialize(*)
      super

      @default_formatter = Formatter.new
    end
  end

  class Logger::Formatter # rubocop:disable Style/ClassAndModuleChildren
    FORMAT = "%s, [%s #%d:%s] %5s -- %s: %s\n"

    def call(severity, time, progname, msg)
      format(
        FORMAT,
        severity[0..0],
        format_datetime(time.utc),
        Process.pid,
        Thread.current.object_id.to_s(36),
        severity,
        progname,
        msg2str(msg)
      )
    end

    attr_accessor :datetime_format

    def initialize
      @datetime_format = nil
    end

    private

    def format_datetime(time)
      if datetime_format
        time.strftime(datetime_format)
      else
        time.iso8601(3)
      end
    end

    def msg2str(msg)
      case msg
      when ::String
        msg
      when ::Exception
        "#{msg.message} (#{msg.class})\n#{(msg.backtrace || []).join("\n")}"
      else
        msg.inspect
      end
    end
  end
end
