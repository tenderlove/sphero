require 'minitest/autorun'
require_relative "../lib/sphero/request"

class TestSphero < MiniTest::Unit::TestCase
  STUB_REQUEST_ID = 0x05

  def setup
    @stub_request_class = Sphero::Request.
      make_command(Sphero::Request, STUB_REQUEST_ID)
  end

  def test_request_checksum
    stub_request = @stub_request_class.new(0x01, 1, 2)
    assert_equal 243, stub_request.checksum
  end

  def test_packet_body
    auto_reconnect = @stub_request_class.new(0x01, 0, 0x00)
    assert_equal [0, 0x00].pack("C*"), auto_reconnect.packet_body
  end

  def test_request_dlen
    auto_reconnect = @stub_request_class.new(0x01, 0, 0x00)
    assert_equal 3, auto_reconnect.dlen
  end

  def test_request_header
    stub_request = @stub_request_class.new(0x01, 1, 2)
    expected_header = [Sphero::Request::SOP1, Sphero::Request::SOP2, 
                       0x00, STUB_REQUEST_ID, 0x01, 3]

    assert_equal expected_header, stub_request.header
  end
end
