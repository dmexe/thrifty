require 'test_helper'
require 'net/http'
require 'uri'

describe Thrifty::HTTP::Server::PumaServer do

  it "should handle ok request" do
    app    = lambda { |env| [200, {}, ["OK"]] }
    server = Thrifty.http_server.build do |rack|
      rack.run app
    end
    begin
      reply = Net::HTTP.get_response(URI("http://localhost:8080"))
      assert_equal "OK", reply.body
    ensure
      server.stop
    end
  end

  it "should handle failed request" do
    app    = lambda { |env| nil }
    server = Thrifty.http_server.build do |rack|
      rack.run app
    end
    begin
      reply = Net::HTTP.get_response(URI("http://localhost:8080"))
      assert_match(/Rack::Lint::LintError:/, reply.body)
    ensure
      server.stop
    end
  end

end
