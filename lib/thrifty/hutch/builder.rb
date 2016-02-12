require 'thread'

module Thrifty::Hutch
  class Builder
    def initialize
      require 'hutch'

      @url = ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672/'

      @lock = Mutex.new

      Thread.main[:signal_queue] = []

      Thrifty::Signals.register(method(:stop))
    end

    def with_url(url)
      @url = url
      self
    end

    def build
      ::Hutch::Logging.logger = Thrifty.get_logger "Hutch"
      ::Hutch::Config.set(:uri,                 @url)
      ::Hutch::Config.set(:enable_http_api_use, false)
      ::Hutch::Config.set(:error_handlers,      [ErrorHandler.new])
      start
    end

    def stop
      @lock.synchronize do
        if @worker
          @worker.stop
          ::Hutch.disconnect
          @worker = nil
        end
      end
    end

    def start
      @lock.synchronize do
        unless @worker
          ::Hutch.connect
          @worker = ::Hutch::Worker.new(::Hutch.broker, ::Hutch.consumers)
          @worker.setup_queues
        end
      end
    end
  end
end
