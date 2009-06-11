module WWMD
  class VSStubs::VSIndexedStringRef
    include VSStubHelpers

    attr_reader :value

    def initialize(ref)
      @value = ref
    end

    def serialize
      stack = super
      stack << self.write_int(@value)
      return stack
    end

    def to_xml
      xml = super
      xml.add_text(self.value.to_s)
      xml
    end

  end
end
