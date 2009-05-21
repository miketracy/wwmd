module WWMD
  class VSHybridDict < VSClassHelpers
    attr_accessor :value

    def initialize()
      @value = []
    end

    def add(obj1,obj2)
      @value << [obj1,obj2]
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      self.value.each do |k,v|
        stack << k.serialize
        stack << v.serialize
      end
      return stack
    end

    def to_xml
      xml = super
      xml.add_attribute("size",self.value.size.to_s)
      self.value.each do |k,v|
        pair = REXML::Element.new("Pair")
        key = REXML::Element.new("Key")
        key.add_element(k.to_xml)
        val = REXML::Element.new("Value")
        val.add_element(v.to_xml)
        pair.add_element(key)
        pair.add_element(val)
        xml.add_element(pair)
      end
      xml
    end

  end
end
