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
        Response.const_get(name)
      else
        Response
      end
      klass.new header, body
    end

    def packet_header
      format = "C" * header.length
      header.pack format
    end

    def packet_body
      @data.pack @pattern
    end

    def checksum
      unpacked_header_and_body = (packet_header + packet_body).unpack "C*"
      dropped_sops = unpacked_header_and_body.drop 2
      reduced = dropped_sops.reduce(:+) % 256
      ones_complement = ~reduced
      ones_complement & 0xFF
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

    def self.make_command klass, cid, pattern = 'C*', &block
      Class.new(klass) {
        define_method(:initialize) do |seq, *args|
          super(seq, args)
          @cid     = cid
          @pattern = pattern
        end
      }
    end

    SetBackLEDOutput = make_command Sphero, 0x21
    SetRotationRate  = make_command Sphero, 0x03
    SetRGB           = make_command Sphero, 0x20
    GetRGB           = make_command Sphero, 0x22
    Heading          = make_command Sphero, 0x01, 'n'
    Roll             = make_command Sphero, 0x30, 'CnC'

    Ping             = make_command Request, 0x01
    GetVersioning    = make_command Request, 0x02
    GetBluetoothInfo = make_command Request, 0x11
    SetAutoReconnect = make_command Request, 0x12
    GetAutoReconnect = make_command Request, 0x13
    GetPowerState    = make_command Request, 0x20
    Sleep            = make_command Request, 0x22, 'nC'
  end
end
