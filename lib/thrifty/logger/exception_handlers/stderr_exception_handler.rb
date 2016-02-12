module Thrifty::Logger

  class StderrExceptionHanlder
    def initialize(appender = nil)
      @appender = appender || IoAppender.new(STDERR)
    end

    def call(ex, scope, context)
      entry = ExceptionEntry.new(nil, nil, scope, ex, context)
      @appender.call(entry)
    end
  end

end
