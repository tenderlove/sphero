require 'serialport'

class Sphero
  VERSION = '1.0.0'

  class Response
    SOP1 = 0
    SOP2 = 1
    MRSP = 2
    SEQ  = 3
    DLEN = 4

    CODE_OK = 0

    attr_reader :body

    def initialize header, body
      @header = header
      @body   = body
    end

    def empty?
      @header[DLEN] == 1
    end

    def success?
      @header[MRSP] == CODE_OK
    end

    def seq
      @header[SEQ]
    end
  end

  def initialize dev
    @sp = SerialPort.new dev, 115200, 8, 1, SerialPort::NONE
    @dev = 0x00
    @seq = 0x00
  end

  def ping
    write 0x01
  end

  def version
    write 0x02
  end

  def bluetooth_info
    resp = write 0x11
    [resp.body.take(15).pack('C*'), resp.body.drop(15).pack('C*')]
  end

  def auto_reconnect= time_s
    write 0x12, [0x01, time_s]
  end

  def auto_reconnect
    write(0x13).body[1]
  end

  def disable_auto_reconnect
    write 0x12, [0x00, 0x05]
  end

  def roll speed, heading, delay = 0x01
    cmd = [speed, heading >> 8, heading & 0xFF, delay]
    write 0x30, cmd, 0x02
  end

  def stop
    write 0x30, [0x01, 0x00, 0x00, 0x00], 0x02
  end

  def heading= h
    write 0x01, [h >> 8, h & 0xFF], 0x02
  end

  def color red, green, blue
    write 0x20, [red, green, blue], 0x02
  end

  private

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
    s = Sphero.new "/dev/tty.Sphero-PRG-RN-SPP"
  rescue Errno::EBUSY
    p :wtf
    retry
  end

  p s.ping
  p s.roll(125, 0)

  trap(:INT) {
    s.stop
    exit!
  }

  sleep 1
  loop do
  0.step(360, 30) { |h|
    h = 0 if h == 360

    s.heading = h
    sleep 1
  }
  end
  sleep 1
  s.stop
end
