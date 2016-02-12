require 'singleton'
require 'thread'

module Thrifty ; class Signals

  include Singleton

  class << self
    def register(fn)
      instance.register(fn)
    end
  end

  def initialize
    @handlers = []
    @mutex    = Mutex.new
    @resource = ConditionVariable.new
  end

  def install
    %w{INT TERM}.each do |sig|
      trap sig, &method(:shutdown)
    end
  end

  def wait
    @mutex.synchronize do
      @resource.wait(@mutex)
    end
  end

  def register(fn)
    @handlers << fn
  end

  def shutdown
    @handlers.each {|fn| fn.call }

    @mutex.synchronize do
      @resource.signal
    end
  end

end ; end
