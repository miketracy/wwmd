module WWMD
  # gin up all the single byte values
  class VSValue < VSClassHelpers
    attr_accessor :value

    def initialize(str)
      @value = str
    end

    def to_s
      @value.hexify
    end

    def to_sym
      VIEWSTATE_TYPES[opcode].to_sym
    end

    def opcode
      @value
    end

    def serialize
      super # cheat... just return opcode
    end

    def to_xml
      xml = super
      xml.add_text(self.to_sym.to_s)
      xml
    end

  end
end
