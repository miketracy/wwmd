module WWMD
  class VSUnit < VSClassHelpers
    attr_reader :dword
    attr_reader :word
    attr_reader :value

    def initialize(dword,word)
      @dword = dword
      @word = word
      @value = ''
    end

    def serialize
      stack = super
      stack << write_double(self.dword)
      stack << write_single(self.word)
      return stack
    end

    def to_xml
      xml = super
      xml.add_attribute("dword",self.dword.to_s)
      xml.add_attribute("word",self.word.to_s)
      xml
    end

  end
end
