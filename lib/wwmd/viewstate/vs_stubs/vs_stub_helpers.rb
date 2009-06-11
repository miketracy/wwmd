module WWMD
  module VSStubHelpers
    include ViewStateUtils

    def to_sym
      self.class.to_s.split(":").last.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1].gsub(/\Avs/,"").to_sym
    end

    def opcode
      return VIEWSTATE_TYPES.index(self.to_sym)
    end

    def size
      return @value.size
    end

    def serialize
      stack = ""
      stack << self.write_byte(self.opcode)
      if self.respond_to?(:typeref)
        stack << self.serialize_type(self.typeref,self.typeval)
      end
      return stack
    end

    def to_xml
      xml = REXML::Element.new(self.class.to_s.split(":").last)
      if self.respond_to?(:typeref)
        xml.add_attribute("typeref",self.typeref)
        xml.add_attribute("typeval",self.typeval)
      end
#      xml.add_attribute("size",self.size)
      xml
    end
 
  end
end
