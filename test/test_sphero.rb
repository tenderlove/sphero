require 'minitest/autorun'
require 'sphero'

class TestSphero < MiniTest::Unit::TestCase
  def test_ping_checksum
    ping = Sphero::Request::Ping.new 1
    assert_equal 1, ping.checksum
  end
end
