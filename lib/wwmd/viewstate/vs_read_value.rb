module WWMD
  class VSReadValue < VSClassHelpers
    attr_accessor :value

    def initialize(val)
      @value = val
    end

    def serialize
      stack = super
      case self.to_sym
        when :int16;       stack << self.write_short(self.value)
        when :int32;       stack << self.write_7bit_encoded_int(self.value)
        when :byte;        stack << self.write_byte(self.value)
        when :char;        stack << self.write_byte(self.value)
        when :date_time;   stack << self.write_double(self.value)
        when :double;      stack << self.write_double(self.value)
        when :single;      stack << self.write_single(self.value)
        when :color;       stack << self.write_int32(self.value)
        when :known_color; stack << self.write_7bit_encoded_int(self.value)
        else; raise "unimplemented #{self.to_sym}"
      end
      return stack
    end

    def to_xml
      xml = super
      xml.add_text(self.value.to_s)
      xml
    end

  end
end
