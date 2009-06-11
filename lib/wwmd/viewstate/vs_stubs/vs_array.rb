module WWMD
  class VSStubs::VSArray
    include VSStubHelpers

    attr_accessor :value
    attr_reader   :typeref
    attr_reader   :typeval

    def initialize(typeref,typeval)
      @typeref = typeref
      @typeval = typeval
      @value = []
    end

    def add(obj)
      @value << obj
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.value.size)
      self.value.each do |v|
        stack << v.serialize
      end
      return stack
    end

    def to_xml
      xml = super
      xml.add_attribute("size", self.value.size.to_s)
      self.value.each do |v|
        xml.add_element(v.to_xml)
      end
      xml
    end

  end
end
