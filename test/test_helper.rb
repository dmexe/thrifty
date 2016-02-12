require 'minitest/autorun'
require 'minitest/spec'

require "minitest/reporters"

require 'pp'

reporters = [Minitest::Reporters::SpecReporter.new]
reporters << Minitest::Reporters::JUnitReporter.new if ENV['CI']

Minitest::Reporters.use! reporters

require File.expand_path("../../lib/thrifty", __FILE__)
