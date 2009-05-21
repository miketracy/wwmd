module WWMD
  class VSIntEnum < VSClassHelpers
    attr_accessor :value
    attr_reader   :typeref
    attr_reader   :typeval

    def initialize(typeref,typeval,index)
      @typeref = typeref
      @typeval = typeval
      @value = index
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.value)
    end

    def to_xml
      xml = super
      xml.add_text(self.value.to_s)
      xml
    end

  end
end
