require 'thread'

module Thrifty::Hutch
  class Builder
    def initialize
      require 'hutch'

      @url      = ENV['RABBITMQ_URL'] || 'amqp://guest:guest@localhost:5672/'
      @exchange = 'hutch'

      @lock = Mutex.new

      Thread.main[:signal_queue] = []

      Thrifty::Signals.register(method(:stop))
    end

    def with_url(url)
      @url = url
      self
    end

    def with_exchange(name)
      ::Hutch::Config.set(:mq_exchange, name)
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
          ::Hutch::Logging.logger.info "stopping"
          @worker.stop
          ::Hutch.disconnect
          ::Hutch::Logging.logger.info "stopped"
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
