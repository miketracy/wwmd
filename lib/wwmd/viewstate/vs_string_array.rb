module WWMD
  class VSStringArray < VSClassHelpers
    attr_accessor :value

    def initialize()
      @value = []
    end

    def add(obj)
      @value << obj
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      self.value.each do |v|
        stack << self.write_7bit_encoded_int(v.size)
        stack << v
      end
      return stack
    end

    def to_xml
      xml = super
      xml.add_attribute("size",self.value.size.to_s)
      self.value.each do |v|
        xml.add_element(VSString.new(v).to_xml)
      end
      xml
    end

    def from_xml
# serliazed with VSString (for convenience)
# make sure not to deserialize the opcode when you write this out
    end
  end
end
