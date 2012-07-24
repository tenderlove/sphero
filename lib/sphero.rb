require 'serialport'
require 'sphero/request'
require 'sphero/response'

class Sphero
  VERSION = '1.0.0'

  def initialize dev
    @sp = SerialPort.new dev, 115200, 8, 1, SerialPort::NONE
    @dev = 0x00
    @seq = 0x00
  end

  def ping
    write_packet Request::Ping.new(@seq)
  end

  def version
    write_packet Request::GetVersioning.new(@seq)
  end

  def bluetooth_info
    write_packet Request::GetBluetoothInfo.new(@seq)
  end

  def auto_reconnect= time_s
    write_packet Request::SetAutoReconnect.new(@seq, time_s)
  end

  def auto_reconnect
    write_packet(Request::GetAutoReconnect.new(@seq)).time
  end

  def disable_auto_reconnect
    write_packet Request::SetAutoReconnect.new(@seq, 0, false)
  end

  def power_state
    write_packet Request::GetPowerState.new(@seq)
  end

  def sleep wakeup = 0, macro = 0
    write_packet Request::Sleep.new(@seq, wakeup, macro)
  end

  def roll speed, heading, delay = 0x01
    cmd = [speed, heading >> 8, heading & 0xFF, delay]
    write 0x30, cmd, 0x02
  end

  def stop
    write 0x30, [0x01, 0x00, 0x00, 0x00], 0x02
  end

  def heading= h
    write_packet Request::Heading.new(@seq, h)
  end

  private

  def write_packet packet
    @sp.write packet.to_str
    @seq += 1

    header   = @sp.read(5).unpack 'C5'
    body     = @sp.read header.last
    response = packet.response header, body

    if response.success?
      response
    else
      raise response
    end
  end

  def write cmd, data = [], did = @dev
    data_len = data.length + 1

    packet = [0xFF, 0xFF, did, cmd, @seq, data_len] + data
    checksum = packet.drop(2).reduce :+

    packet << ~(checksum % 256)
    @sp.write packet.pack('C*')
    @seq += 1

    header   = @sp.read(5).unpack('C5')
    body     = @sp.read(header.last).unpack 'C*'
    response = Response.new header, body

    if response.success?
      response
    else
      raise response
    end
  end
end


if $0 == __FILE__
  begin
    s = Sphero.new "/dev/tty.Sphero-BRR-RN-SPP"
  rescue Errno::EBUSY
    p :wtf
    retry
  end

  10.times {
    p s.ping
  }

  0.step(360, 1) { |i|
    i = 0 if i == 360
    s.heading = i
    sleep 0.5
  }
end
