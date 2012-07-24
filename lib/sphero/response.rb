class Sphero
  class Response
    SOP1 = 0
    SOP2 = 1
    MRSP = 2
    SEQ  = 3
    DLEN = 4

    CODE_OK = 0

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

    def body
      @body.unpack 'C*'
    end

    class GetAutoReconnect < Response
      def time
        body[1]
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
  end
end
