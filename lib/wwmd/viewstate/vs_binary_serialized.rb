module WWMD
  class VSBinarySerialized < VSClassHelpers
    attr_accessor :value

    def initialize()
      @value = ''
    end

    def set(str)
      @value = str
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      stack << self.value
      return stack
    end

    def to_xml
      xml = super
      xml.add_attribute("encoding","base64")
      xml.add_text(self.value.b64e)
      xml
    end

  end
end
