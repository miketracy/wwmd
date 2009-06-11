module WWMD
  class VSStubs::VSTriplet
    include VSStubHelpers

    attr_accessor :value

    def initialize(obj1,obj2,obj3)
      @value = []
      @value << obj1
      @value << obj2
      @value << obj3
    end

    def serialize
      stack = super
      self.value.each do |v|
        stack << v.serialize
      end
      return stack
    end

    def to_xml
      xml = super
      self.value.each do |v|
        xml.add_element(v.to_xml)
      end
      xml
    end

  end
end
