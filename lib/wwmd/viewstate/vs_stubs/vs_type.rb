module WWMD
  class VSStubs::VSType
    include VSStubHelpers

    attr_accessor :value
    attr_reader   :typeref
    attr_reader   :typeval

    def initialize(typeref,typeval)
      @typeref = typeref
      @typeval = typeval
    end

    def serialize
      super # cheat opcode + typeref + typeval
    end

    def to_xml
      super
    end

  end
end
