module Thrifty::Logger
  class IoAppender
    def initialize(io = nil, formatter = nil)
      @io        = io || STDOUT
      is_tty     = @io.respond_to?(:tty?) && @io.tty?
      @formatter = formatter || (is_tty ? SimpleFormatter.new : LogfmtFormatter.new)
    end

    def call(entry)
      @formatter.call(entry).each{|line| @io.puts line }
    end
  end
end
