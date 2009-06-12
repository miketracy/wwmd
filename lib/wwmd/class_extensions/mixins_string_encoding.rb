=begin rdoc
Place methods to character encodings here
=end

module WWMD
  # This is where character encodings should go as module methods
  # to be used as mixins for the String class
  module Encoding

    # String.to_utf7 mixin
    # (complete hack but it works)
    #
    # if all=true, encode all characters.
    # if all.class=Regexp encode only characters in the passed
    # regular expression else default to /[^0-9a-zA-Z]/
    #
    # used by:
    #  String.to_utf7
    #  String.to_utf7!
    def to_utf7(all=nil)
      if all.kind_of?(Regexp)
        reg = all
      elsif all.kind_of?(TrueClass)
        reg = ESCAPE[:all]
      else
        reg = ESCAPE[:nalnum] || /[^a-zA-Z0-9]/
      end
      puts reg.inspect
      ret = ''
      self.each_byte do |b|
        if b.chr.match(reg)
          ret += "+" + Base64.encode64(b.chr.toutf16)[0..2] + "-"
        else
          ret += b.chr
        end
      end
      return ret
    end
  end
end
