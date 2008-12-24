# Author Eric Monti (emonti@matasano.com)
require "base64"
require "stringio"
require 'zlib'
require 'open3'
require 'sha1'

HEXCHARS = [("0".."9").to_a, ("a".."f").to_a].flatten

#-----------------------------------------------------------------------------
# Mixins and class-specific items

class String

  # shortcut for hex sanity with regex
  def ishex? ; (self =~ /^[a-f0-9]+$/i)? true : false ; end 

  # Convert a string to ASCII hex string
  # supports a few options for format:
  #   :delim - delimter between each hex byte
  #   :prefix - prefix before each hex byte
  #   :suffix - suffix after each hex byte
  # 
  def hexify(opts={})
    s=self
    delim = opts[:delim]
    pre = (opts[:prefix] || "")
    suf = (opts[:suffix] || "")

    if (rx=opts[:rx]) and not rx.kind_of? Regexp
      raise "rx must be a regular expression for a character class"
    end

    out=Array.new

    s.each_byte do |c| 
      hc = if (rx and not rx.match c.chr)
             c.chr 
           else
             pre + (HEXCHARS[(c >> 4)] + HEXCHARS[(c & 0xf )]) + suf
           end
      out << (hc)
    end
    out.join(delim)
  end


  # Convert ASCII hex string to raw
  # supports only 'delimiter' between hex bytes
  def unhexify(d=/\s*/)
    s=self.strip
    out=StringIO.new
    while m = s.match(/^([A-Fa-f0-9]{1,2})#{d}?/) do
      out.write m[1].hex.chr
      s = m.post_match
    end
    out.string
  end

  # ==========================================================================
  # Extends String class to return a hexdump in the style of 'hexdump -C'
  #
  # :len => optionally specify a length other than 16 for a wider or thinner 
  # dump. If length is an odd number, it will be rounded up.
  #
  # :out => optionally specify an alternate IO object for output. By default,
  # hexdump will output to STDOUT.  Pass a StringIO object and it will return 
  # it as a string.
  #
  # Example:
  # xxd = dat.hexdump(:len => 16, :out => StringIO.new)
  # xxd => a hexdump
  #
  # xxd = dat.hexdump(:len => 16, :out => STDERR)
  # xxd => nil
  # ==========================================================================
  def hexdump(opt={})
    s=self
    out = opt[:out] || StringIO.new
    len = (opt[:len] and opt[:len] > 0)? opt[:len] + (opt[:len] % 2) : 16

    off = opt[:start_addr] || 0
    offlen = opt[:start_len] || 8

    hlen=len/2

    s.scan(/(?:.|\n){1,#{len}}/) do |m|
      out.write(off.to_s(16).rjust(offlen, "0") + '  ')

      i=0
      m.each_byte do |c|
        out.write c.to_s(16).rjust(2,"0") + " "
        out.write(' ') if (i+=1) == hlen
      end

      out.write("   " * (len-i) ) # pad
      out.write(" ") if i < hlen

      out.write(" |" + m.tr("\0-\37\177-\377", '.') + "|\n")
      off += m.length
    end

    out.write(off.to_s(16).rjust(offlen,'0') + "\n")

    if out.class == StringIO
      out.string
    end
  end


  # ==========================================================================
  # converts a hexdump back to binary - takes the same options as hexdump()
  # fairly flexible. should work both with 'xxd' and 'hexdump -C' style dumps
  def dehexdump(opt={})
    s=self
    out = opt[:out] || StringIO.new
    len = (opt[:len] and opt[:len] > 0)? opt[:len] : 16

    hcrx = /[A-Fa-f0-9]/
    dumprx = /^(#{hcrx}+):?\s*((?:#{hcrx}{2}\s*){0,#{len}})/
    off = opt[:start_addr] || 0

    i=1
    # iterate each line of hexdump
    s.split(/\r?\n/).each do |hl|
      # match and check offset
      if m = dumprx.match(hl) and $1.hex == off
        i+=1
        # take the data chunk and unhexify it
        raw = $2.unhexify
        off += out.write(raw)
      else
        raise "Hexdump parse error on line #{i} #{s}"
      end
    end

    if out.class == StringIO
      out.string
    end
  end
  alias dedump dehexdump

  # Does string "start with" dat?
  # no clue whether/when this is faster than a regex, but it is easier 
  # than escaping regex characters
  def starts_with?(dat)
    self[0,dat.size] == dat
  end

  # returns CRC32 checksum for the string object
  def crc32
    Zlib.crc32 self
  end

	def swap16; unpack("v*").pack("n*"); end
	def to_utf16; Kconv.kconv(self, NKF::UTF16, NKF::ASCII).swap16; end
	def to_ascii; Kconv.kconv(swap16, NKF::ASCII, NKF::UTF16); end

end # class String


class Float
  def log2; Math.log(self)/Math.log(2); end
end

__END__
