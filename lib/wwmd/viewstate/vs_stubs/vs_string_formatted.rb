module WWMD
  class VSStubs::VSStringFormatted
    include VSStubHelpers

    attr_accessor :value
    attr_reader   :typeref
    attr_reader   :typeval

    def initialize(typeref,typeval,str)
      @typeref = typeref
      @typeval = typeval
      @value = str
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      stack << self.value
    end

    def to_xml
      xml = super
      xml.add_element(VSStubs::VSString.new(self.value).to_xml)
      xml
    end

    def from_xml
# deserialize convenience VSString properly
    end

  end
end
