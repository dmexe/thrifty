module Thrifty

  extend self

  def get_logger(*args)
    Thrifty::Logger.get_logger(*args)
  end

  def http_server
    Thrifty::HTTP::Server::Builder.new
  end

  def hutch
    Thrifty::Hutch::Builder.new
  end

  def signals
    Thrifty::Signals.instance
  end
end

require File.expand_path("../thrifty/signals",     __FILE__)
require File.expand_path("../thrifty/logger",      __FILE__)
require File.expand_path("../thrifty/http_server", __FILE__)
require File.expand_path("../thrifty/hutch",       __FILE__)
