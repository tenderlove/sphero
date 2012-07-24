require 'minitest/autorun'
require 'sphero'

class TestSphero < MiniTest::Unit::TestCase
  def test_ping_checksum
    ping = Sphero::Request::Ping.new 0
    assert_equal "\xFF\xFF\x00\x01\x00\x01\xFD", ping.to_str
  end

  def test_sleep_dlen
    sleep = Sphero::Request::Sleep.new 0, 0, 0
    assert_equal 0x04, sleep.dlen
  end
end
