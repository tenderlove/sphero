require 'serialport'
require 'sphero/request'
require 'sphero/response'
require 'thread'

class Sphero
  VERSION = '1.0.0'

  def initialize dev
    @sp   = SerialPort.new dev, 115200, 8, 1, SerialPort::NONE
    @dev  = 0x00
    @seq  = 0x00
    @lock = Mutex.new
  end

  def ping
    write Request::Ping.new(@seq)
  end

  def version
    write Request::GetVersioning.new(@seq)
  end

  def bluetooth_info
    write Request::GetBluetoothInfo.new(@seq)
  end

  def auto_reconnect= time_s
    write Request::SetAutoReconnect.new(@seq, time_s)
  end

  def auto_reconnect
    write(Request::GetAutoReconnect.new(@seq)).time
  end

  def disable_auto_reconnect
    write Request::SetAutoReconnect.new(@seq, 0, 0x00)
  end

  def power_state
    write Request::GetPowerState.new(@seq)
  end

  def sleep wakeup = 0, macro = 0
    write Request::Sleep.new(@seq, wakeup, macro)
  end

  def roll speed, heading, state = true
    write Request::Roll.new(@seq, speed, heading, state ? 0x01 : 0x00)
  end

  def stop
    roll 0, 0
  end

  def heading= h
    p :heading => h
    heading = Request::Heading.new(@seq, h)
    p Request::Heading
    p heading
    p heading.packet_body
    write Request::Heading.new(@seq, h)
  end

  def rgb r, g, b, persistant = false
    write Request::SetRGB.new(@seq, r, g, b, persistant ? 0x01 : 0x00)
  end

  # This retrieves the "user LED color" which is stored in the config block
  # (which may or may not be actively driven to the RGB LED).
  def user_led
    write Request::GetRGB.new(@seq)
  end

  # Brightness 0x00 - 0xFF
  def back_led_output= h
    write Request::SetBackLEDOutput.new(@seq, h)
  end

  # Rotation Rate 0x00 - 0xFF
  def rotation_rate= h
    write Request::SetRotationRate.new(@seq, h)
  end

  private

  def write packet
    header = nil
    body   = nil

    @lock.synchronize do
      @sp.write packet.to_str
      @seq += 1

      header   = @sp.read(5).unpack 'C5'
      body     = @sp.read header.last
    end

    response = packet.response header, body

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
    retry
  end

  10.times {
    p s.ping
  }

  trap(:INT) {
    s.stop
    exit!
  }

  #s.roll 100, 0

  p s.user_led
  exit
  loop do
    [0, 180].each do |dir|
      s.heading = dir
      sleep 10
    end

    #[
    #  [0, 0, 0xFF],
    #  [0xFF, 0, 0],
    #  [0, 0xFF, 0],
    #].each do |color|
    #  s.rgb(*color)
    #  sleep 5
    #end
  end

  #36.times {
  #  i = 10
  #  p :step => i
  #  s.heading = i
  #  sleep 0.5
  #}
end
