module WWMD
  class VSStubs::VSSparseArray
    include VSStubHelpers

    attr_accessor :value
    attr_reader   :typeref
    attr_reader   :typeval
    attr_reader   :size
    attr_reader   :elems

    def initialize(typeref,typeval,size,elems)
      @typeref = typeref
      @typeval = typeval
      @size = size
      @elems = elems
      @value = []
    end

    def add(idx,obj)
      @value[idx] = obj
    end

    def serialize
      stack = super
      stack << self.write_7bit_encoded_int(self.size)
      stack << self.write_7bit_encoded_int(self.elems)                             
      self.value.each_index do |i|
        next if self.value[i].nil?
        stack << self.write_7bit_encoded_int(i)
        stack << self.value[i].serialize
      end
      return stack
    end

    def to_xml
      xml = super
      siz = REXML::Element.new("Size")
      siz.add_text(self.size.to_s)
      ele = REXML::Element.new("Elements")
      ele.add_text(self.elems.to_s)
      xml.add_element(siz)
      xml.add_element(ele)
      self.value.each_index do |i|
        next if self.value[i].nil?
        pair = REXML::Element.new("Pair")
        idx = REXML::Element.new("Index")
        idx.add_text(i.to_s)
        val = REXML::Element.new("Value")
        val.add_element(value[i].to_xml)
        pair.add_element(idx)
        pair.add_element(val)
        xml.add_element(pair)
      end
      xml
    end

  end
end
