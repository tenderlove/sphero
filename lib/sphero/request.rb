class Sphero
  class Request
    SOP1 = 0xFF
    SOP2 = 0xFF

    def initialize seq, data = []
      @seq    = seq
      @data   = data
      @did    = 0x00
      @dlen   = @data.length + 1
      @format = 'C*'
    end

    def data_bytes
      [SOP1, SOP2, @did, @cid, @seq, @dlen] + @data
    end

    def checksum
      ~(data_bytes.drop(2).reduce(:+) % 256) & 0xFF
    end

    def bytes
      data_bytes << checksum
    end

    # The data to write to the socket
    def to_str
      bytes.pack @format
    end

    def response header, body
      Response.new header, body
    end

    class Ping < Request
      def initialize seq
        super(seq, [])
        @cid  = 0x01
      end
    end

    class GetVersioning < Request
      def initialize seq
        super(seq, [])
        @cid  = 0x02
      end
    end

    class GetBluetoothInfo < Request
      def initialize seq
        super(seq, [])
        @cid  = 0x11
      end

      def response header, body
        Response::GetBluetoothInfo.new header, body
      end
    end

    class SetAutoReconnect < Request
      def initialize seq, time = 7, enabled = true
        super(seq, [enabled ? 0x01 : 0x00, time])
        @cid = 0x12
      end
    end

    class GetAutoReconnect < Request
      def initialize seq
        super(seq, [])
        @cid = 0x13
      end

      def response header, body
        Response::GetAutoReconnect.new header, body
      end
    end

    class GetPowerState < Request
      def initialize seq
        super(seq, [])
        @cid = 0x20
      end

      def response header, body
        Response::GetPowerState.new header, body
      end
    end
  end
end
