class Sphero
  class Exception < RuntimeError
  end

  class Response
    SOP1 = 0
    SOP2 = 1
    MRSP = 2
    SEQ  = 3
    DLEN = 4

    CODE_OK           = 0x0
    CODE_EGEN         = 0x1
    CODE_ECHKSUM      = 0x2
    CODE_EFRAG        = 0x3
    CODE_EBAD_CMD     = 0x4
    CODE_EUNSUPP      = 0x5
    CODE_EBAD_MSG     = 0x06
    CODE_EPARAM       = 0x07
    CODE_EEXEC        = 0x08
    CODE_EBAD_DID     = 0x09
    CODE_POWER_NOGOOD = 0x31
    CODE_PAGE_ILLEGAL = 0x32
    CODE_FLASH_FAIL   = 0x33
    CODE_MA_CORRUPT   = 0x34
    CODE_MSG_TIMEOUT  = 0x35

    CODE_TO_MESSAGE = {
      CODE_OK           => 'Command succeeded',
      CODE_EGEN         => 'General, non-specific error',
      CODE_ECHKSUM      => 'Received checksum failure',
      CODE_EFRAG        => 'Received command fragment',
      CODE_EBAD_CMD     => 'Unknown command ID',
      CODE_EUNSUPP      => 'Command currently unsupported',
      CODE_EBAD_MSG     => 'Bad message format',
      CODE_EPARAM       => 'Parameter value(s) invalid',
      CODE_EEXEC        => 'Failed to execute command',
      CODE_EBAD_DID     => 'Unknown Device ID',
      CODE_POWER_NOGOOD => 'Voltage too low for reflash operation',
      CODE_PAGE_ILLEGAL => 'Illegal page number provided',
      CODE_FLASH_FAIL   => 'Page did not reprogram correctly',
      CODE_MA_CORRUPT   => 'Main Application corrupt',
      CODE_MSG_TIMEOUT  => 'Msg state machine timed out',
    }
    CODE_TO_EXCEPTION = {}

    CODE_TO_MESSAGE.each do |k,v|
      next if k == CODE_OK
      CODE_TO_EXCEPTION[k] = Exception.new(v)
    end

    def initialize header, body
      @header = header
      @body   = body
    end

    def exception
      CODE_TO_EXCEPTION[MRSP]
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

    def body
      @body.unpack 'C*'
    end

    class GetAutoReconnect < Response
      def time
        body[1]
      end
    end

    class GetPowerState < Response
      # constants for power_state
      CHARGING = 0x01
      OK       = 0x02
      LOW      = 0x03
      CRITICAL = 0x04

      def body
        @body.unpack 'CCnnnC'
      end

      def rec_ver
        body[0]
      end

      def power_state
        body[1]
      end

      # Voltage * 100
      def batt_voltage
        body[2]
      end

      def num_charges
        body[3]
      end

      # Time since awakened in seconds
      def time_since_charge
        body[4]
      end
    end

    class GetBluetoothInfo < Response
      def name
        body.take(16).slice_before(0x00).first.pack 'C*'
      end

      def bta
        body.drop(16).slice_before(0x00).first.pack 'C*'
      end
    end

    class GetRGB < Response
      def r; body[0]; end
      def g; body[1]; end
      def b; body[2]; end
    end
  end
end
