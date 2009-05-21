module WWMD
  attr_accessor :value

  class VSString < VSClassHelpers
    def initialize(val)
      @value = val
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      stack << self.value
      return stack
    end

    def to_xml
      xml = super
      # emit quoted-printable if we need to
      if self.value =~ /[^\x20-\x7e]/
        xml.add_attribute("encoding","quoted-printable")
        xml.add_text(self.value.to_qp)
      else
        xml.add_text(self.value)
      end
      xml
    end

  end
end
