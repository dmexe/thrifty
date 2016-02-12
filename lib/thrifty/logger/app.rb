require 'thread'
require 'singleton'

module Thrifty::Logger
  class App

    include Singleton

    def initialize
      @queue = Queue.new
      @lock  = Mutex.new

      Thrifty::Signals.register_after(method(:stop))
    end

    def start
      @lock.synchronize do
        unless @thread
          @thread = main_loop
        end
      end
    end

    def started?
      !!@thread
    end

    def stop
      @lock.synchronize do
        return unless @thread
        append(new_entry("stopping"))
        append(:shutdown)
        @thread.join
        @thread = nil
        App.append(new_entry("stopped"))
      end
    end

    def append(entry)
      @queue.push(entry) if @thread
    end

    private

      def new_entry(msg)
        Entry.new(
          :info,
          Time.now,
          self.class,
          msg
        )
      end

      def main_loop ; Thread.new do
        begin
          loop do
            entry = @queue.pop
            if entry == :shutdown
              break
            end
            if entry == :boom
              raise RuntimeError.new("ignore me")
            end
            App.append(entry)
          end
        rescue Exception => ex
          App.handle_exception(ex, self.class)
          retry
        end
      end ; end
  end

  class App
    class << self
      @@appenders          = [IoAppender.new]
      @@exception_handlers = [StderrExceptionHanlder.new]

      def appenders(*fn)
        @@appenders = fn.flatten
      end

      def exception_handlers(*fn)
        @@exception_handlers = fn.flatten
      end

      def append(entry)
        @@appenders.each{|fn| fn.call(entry) }
      end

      def handle_exception(ex, scope = nil, context = {})
        @@exception_handlers.each{|fn| fn.call(ex, scope, context) }
      end

      def reset!
        @@appenders          = [IoAppender.new]
        @@exception_handlers = [StderrExceptionHanlder.new]
      end
    end
  end
end
