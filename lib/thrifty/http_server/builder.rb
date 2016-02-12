module Thrifty::HTTP::Server
  class Builder

    def initialize
      require 'rack'
      require 'puma'

      @port = nil
      @ip   = nil
      @name = nil
    end

    def with_port(value)
      @port = value.to_i
      self
    end

    def with_ip(value)
      @ip = value
      self
    end

    def with_name(value)
      @name = value
      self
    end

    def build(&block)
      server = PumaServer.new(ip: @ip, port: @port, &block)
      server.start
      server
    end
  end
end
