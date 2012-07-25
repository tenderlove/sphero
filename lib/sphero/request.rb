class Sphero
  class Request
    SOP1 = 0xFF
    SOP2 = 0xFF

    attr_reader :data

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
      name = self.class.name.split('::').last
      klass = if Response.const_defined?(name)
        Response.const_get(name).new header, body
      else
        Response.new header, body
      end
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

    def self.make_command klass, cid, &block
      Class.new(klass) {
        define_method(:initialize) do |seq, *args|
          super(seq, args)
          @cid = cid
        end
      }
    end

    SetBackLEDOutput = make_command Sphero, 0x21
    SetRotationRate  = make_command Sphero, 0x03
    SetRGB           = make_command Sphero, 0x20

    class GetRGB < Sphero
      def initialize seq
        super(seq, [])
        @cid = 0x22
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
    end

    class GetPowerState < Request
      def initialize seq
        super(seq, [])
        @cid = 0x20
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
