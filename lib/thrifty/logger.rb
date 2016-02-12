module Thrifty ; module Logger
  TRACE = 0
  DEBUG = 1
  INFO  = 2
  WARN  = 3
  ERROR = 4
  FATAL = 5

  LEVELS = ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'].freeze

  def self.get_logger(scope, context = nil)
    App.instance.start unless App.instance.started?
    Context.new(App.instance, scope.to_s, context)
  end

  def self.stop
    App.instance.stop
  end

  def logfmt_formatter
    LogfmtFormatter.new
  end

  def simple_formatter
    SimpleFormatter.new
  end

  def io_appender(*args)
    IoAppender.new(*args)
  end
end ; end

%w{
  entry
  formatters/logfmt_formatter
  formatters/simple_formatter
  appenders/io_appender
  exception_handlers/stderr_exception_handler
  app
  context
}.each do |f|
  require File.expand_path("../logger/#{f}", __FILE__)
end
