require 'singleton'
require 'thread'

module Thrifty ; class Signals

  include Singleton

  class << self
    def register(fn)
      instance.install
      instance.register(fn)
    end

    def register_after(fn)
      instance.install
      instance.register_after(fn)
    end
  end

  def initialize
    @handlers  = []
    @after     = []
    @mutex     = Mutex.new
    @resource  = ConditionVariable.new
    @installed = false
  end

  def install
    unless @installed
      %w{INT TERM}.each do |sig|
        trap sig do
          Thread.new{ shutdown }.join
        end
      end
      @installed = true
    end
  end

  def wait
    begin
      @mutex.synchronize do
        @resource.wait(@mutex)
      end
    rescue ::Interrupt
      shutdown
    end
  end

  def register(fn)
    @handlers << fn
  end

  def register_after(fn)
    @after << fn
  end

  def shutdown(sig = nil)
    @handlers.each {|fn| fn.call }
    @after.each {|fn| fn.call }

    @mutex.synchronize do
      @resource.signal
    end
  end

end ; end
