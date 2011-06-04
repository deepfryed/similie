require_relative '../ext/similie'

require 'minitest/unit'
require 'minitest/spec'

$testdir = File.absolute_path(File.dirname(__FILE__))

MiniTest::Unit.autorun
