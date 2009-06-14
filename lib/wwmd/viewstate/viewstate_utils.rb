module WWMD
  module ViewStateUtils

    def putd(msg)
      puts(msg) if self.debug
    end

    def slog(obj,msg=nil)
      raise "No @value" if not obj.respond_to?(:value)
      raise "No @size"  if not obj.respond_to?(:size)
      return nil if !self.debug
      putd "#{@stack.size.to_s(16).rjust(8,"0")} [0x#{obj.opcode.to_s(16)}] #{obj.class}: #{msg}"
    end

    def dlog(t,msg)
      raise "null token passed to dlog()" if t.nil?
      o = WWMD::VIEWSTATE_TYPES[t]
      @obj_counts[o] ||= 0
      @obj_counts[o] += 1
      return nil if !self.debug
      putd "#{self.last_offset} [0x#{t.to_s(16).rjust(2,"0")}] #{VIEWSTATE_TYPES[t]}: #{msg}"
    end

    def write_7bit_encoded_int(val)
      s = ""
      while (val >= 0x80) do
        s << [val | 0x80].pack("C")
        val = val >> 7
      end
      s << [val].pack("C")
      return s
    end

    # why oh why did I have to go find this?
    # System.IO.BinaryReader.Read7BitEncodedInt
    def read_7bit_encoded_int(buf=nil)
      l = 0  # length
      s = 0  # shift
      b = "" # byte
      buf = buf.scan(/./m) if buf
      begin
        if not buf
          b = self.read_int
        else
          b = buf.shift.unpack("C").first
        end
        l |= (b & 0x7f) << s
        s += 7
      end while ((b & 0x80) != 0)
      return l
    end

    def read_string
      len = read_7bit_encoded_int
      starr = []
      (1..len).each { |i| starr << @bufarr.shift }
      return starr.to_s
#      @bufarr.slice!(0..(len - 1)).join("")
    end

    def read(count)
      @bufarr.slice!(0..(count - 1)).join("")
    end

    def read_int
      @bufarr.shift.unpack("C").first
    end
    alias_method :read_byte, :read_int

    def write_int(val)
      [val].pack("C")
    end
    alias_method :write_byte, :write_int

    def read_short
      self.read(2).unpack("S").first
    end

    def write_short(val)
      [val].pack("n")
    end

    def read_int32
      @bufarr.slice!(0..3).join("").unpack("L").first
    end
    alias_method :read_single, :read_int32

    def write_int32(val)
      [val].pack("I")
    end
    alias_method :write_single, :write_int32

    def read_double
      @bufarr.slice!(0..7).join("").unpack("Q").first
    end

    def write_double(val)
      [val].pack("Q")
    end

    def magic?
      @magic = [@bufarr.shift,@bufarr.shift].join("")
      VIEWSTATE_MAGIC.include?(@magic)
    end

    def read_raw_byte
      @bufarr.shift
    end

    def serialize_type(op,ref)
      op_str = [op].pack("C")
      s = op_str
      case op
        when VIEWSTATE_TYPES.index(:typeref)
          s << write_7bit_encoded_int(ref)
        when VIEWSTATE_TYPES.index(:typeref_add_local)
          s << write_7bit_encoded_int(ref.size)
          s << ref
        when VIEWSTATE_TYPES.index(:typeref_add)
          s << write_7bit_encoded_int(ref.size)
          s << ref
        else
          raise "Invalid Type Error #{op.to_s(16)}"
      end
      return s
    end

    def deserialize_type(t=nil)
      op = self.read_byte
      case op
        when VIEWSTATE_TYPES.index(:typeref)
          type = read_7bit_encoded_int
          return [op,type]
        when VIEWSTATE_TYPES.index(:typeref_add_local)
          name  = read_string
          return [op,name]
        when VIEWSTATE_TYPES.index(:typeref_add)
          name  = read_string
          return [op,name]
        else
          raise "Invalid Type Error 0x#{op.to_s(16)}"
      end
    end

    def offset(cur=nil)
        (self.size - @bufarr.size).to_s(16).rjust(8,"0")
    end

    def throw(t=nil)
      STDERR.puts "==== Error at Type 0x#{t.to_s(16).rjust(2,"0")}"
      STDERR.puts "offset: #{self.offset}"
      STDERR.puts "left:   #{@bufarr.size}"
      STDERR.puts @bufarr[0..31].join("").hexdump
    end

    def next_type
      t = @bufarr.first.unpack("C").first
      throw(t) if not VIEWSTATE_TYPES.include?(t)
      VIEWSTATE_TYPES[t]
    end
  end
end
