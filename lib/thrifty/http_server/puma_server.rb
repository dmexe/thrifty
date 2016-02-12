require 'thread'

module Thrifty::HTTP::Server
  class PumaServer

    attr_reader :log

    DEFAULT_PORT   = ENV['PORT'].to_i > 0 ? ENV['PORT'] : 8080
    DEFAULT_IP     = '0.0.0.0'
    DEFAULT_MIN_TH = 20
    DEFAULT_MAX_TH = 20

    def initialize(options={})
      port  = options[:port] || DEFAULT_PORT
      ip    = options[:ip]   || DEFAULT_IP
      min   = options[:min]  || DEFAULT_MIN_TH
      max   = options[:max]  || DEFAULT_MAX_TH
      name  = options[:name] || "Thrifty::HTTP::Server"

      @log  = Thrifty.get_logger(name)
      @bind = "#{ip}:#{port}"
      @lock = Mutex.new

      app = ::Rack::Builder.new do
        if options[:err] != false
          use ErrMiddleware, name
        end

        if options[:log] != false
          use LogMiddleware, name
        end

        use Rack::Lint
        yield self
      end

      @server = Puma::Server.new(app)
      @server.add_tcp_listener ip, port
      @server.min_threads = min
      @server.max_threads = max

      Thrifty::Signals.register(method(:stop))
    end

    def start
      @lock.synchronize do
        unless @thread
          log.info "starting", version: Puma::Server::VERSION, bind: @bind, threads: "#{@server.min_threads}:#{@server.max_threads}"
          @thread = @server.run
        end
      end
    end

    def stop
      @lock.synchronize do
        if @thread
          log.info "stopping"
          @server.stop(true)
          @thread.join
          @thread = nil
          log.info "stopped"
        end
      end
    end

  end
end
