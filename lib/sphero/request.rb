class Sphero
  class Request
    SOP1 = 0xFF
    SOP2 = 0xFF

    def initialize seq, data = []
      @seq    = seq
      @data   = data
      @did    = 0x00
    end

    def header
      [SOP1, SOP2, @did, @cid, @seq, dlen]
    end

    # The data to write to the socket
    def to_str
      bytes
    end

    def response header, body
      Response.new header, body
    end

    def packet_header
      header.pack 'CCCCCC'
    end

    def packet_body
      @data.pack 'C*'
    end

    def checksum
      ~((packet_header + packet_body).unpack('C*').drop(2).reduce(:+) % 256) & 0xFF
    end

    def bytes
      packet_header + packet_body + checksum.chr
    end

    def dlen
      packet_body.bytesize + 1
    end

    class Sphero < Request
      def initialize seq, data = []
        super
        @did = 0x02
      end
    end

    class Heading < Sphero
      def initialize seq, heading
        super(seq, [heading])
        @cid  = 0x01
      end

      private
      def packet_body
        @data.pack 'n'
      end
    end

    class SetBackLEDOutput < Sphero
      def initialize seq, brightness
        super(seq, [brightness])
        @cid = 0x21
      end
    end

    class SetRotationRate < Sphero
      def initialize seq, rate
        super(seq, [rate])
        @cid = 0x03
      end
    end

    class RGB < Sphero
      def initialize seq, r, g, b, persistant
        super(seq, [r, g, b, persistant])
        @cid = 0x20
      end
    end

    class Roll < Sphero
      def initialize seq, speed, heading, delay
        super(seq, [speed, heading, delay])
        @cid = 0x30
      end

      private
      def packet_body
        @data.pack 'CnC'
      end
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
      def initialize seq, time = 7, enabled = 0x01
        super(seq, [enabled, time])
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

    class Sleep < Request
      def initialize seq, wakeup, macro
        super(seq, [wakeup, macro])
        @cid    = 0x22
      end

      private

      def packet_body
        @data.pack 'nC'
      end
    end
  end
end
