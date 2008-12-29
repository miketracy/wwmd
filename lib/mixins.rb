#!/usr/bin/env ruby
=begin rdoc
:include:../sig.do

mixins all around
=end

alias putd puts#:nodoc:
alias putx puts#:nodoc:
alias putw puts#:nodoc:

# I really hate this
class NilClass#:nodoc:
  def empty?; return true; end
  def size;   return 0;    end
  def to_form; return FormArray.new([]); end
  def clop; return nil; end
  def inner_html; return nil; end
  def get_attribute(*args); return nil; end
  def grep(*args); return []; end
  def escape(*args); return nil; end
end

class Numeric
  # return binary representation of <tt>length</tt> size padded with \x00
  #  length:  length in bytes to return (padded with least signficant \x00
  #  reverse: reverse the byte order
  def to_bin (len,rev = false)
    str = ""
    bignum = self
    1.upto(len) do |i|
      str << (bignum & 0xFF).to_n8
      bignum = bignum >> 8  
    end
    return str.reverse if rev
    return str
  end

  # integer to ip address
  def int_to_ip
    [24, 16, 8, 0].collect {|b| (self >> b) & 255}.join('.')
  end

  # integer to mac address [uses ':' as delimiter]
  def int_to_mac
    [40,32,24,16,8,0].collect {|b| ((self >> b) & 255).to_s(16).rjust(2,"0")}.join(":")
  end
end

class String

  @@he = HTMLEntities.new

  # ip address to int
  def ip_to_int
    self.split('.').inject(0) {|total,value| (total << 8 ) + value.to_i}
  end

  # mac address to int [uses ':' as delimiter]
  def mac_to_int
    self.split(':').inject(0) {|total,value| (total << 8) + value.to_i(16)}
  end

  # return true or false for <tt>string.match</tt>  
  def contains?(rexp)
    return false if self.match(rexp).nil?
    return true
  end

  # strip the string and return true if empty
  def empty?
    return true if self.strip == ''
  end

  # return everything in the string (url) before the first get param
  ## "http://foo.bar.com/page.asp?somearg=foo&otherarg=bar".clip  
  ## => "http://foo.bar.com/page.asp"
  def clip(pref="?")
    if (v = self.index(pref))
      return self[0..(v-1)]
    end
    return self
  end

  # return everything in the string (url) after the first get parameter
  # without the leading '?'
  #
  # pass true as the second param to also get back the ?
  ## "http://foo.bar.com/page.asp?somearg=foo&otherarg=bar".clop 
  ## => "somearg=foo&otherarg=bar"
  def clop(pref="?",preftoo=false)
    (preftoo == false) ? add = "" : add = pref
    if (v = self.index(pref))
      return add + self[(v+1)..-1]
    end
    return nil
  end

  def clopp; self.clop("?",true); end #:nodoc:

  # base 64 decode
  def b64d
    Base64.decode64(self)
  end

  # base 64 encode
  def b64e
    Base64.encode64(self).split("\n").join
  end

  # URI.escape using defaults or passed regexp
  def escape(reg=WWMD::ESCAPE[:default],unicodify=false)
    if reg == WWMD::ESCAPE[:none] then
      return self
    elsif reg == WWMD::ESCAPE[:default] then
      ret = URI.escape(self)
    elsif reg.kind_of?(Symbol) then
      ret = URI.escape(self,WWMD::ESCAPE[reg])
      reg = WWMD::ESCAPE[reg]
    else
      ret = URI.escape(self,reg)
    end
    if unicodify then
      ret.gsub!(/%/,"%u00")
    end
    return ret
  end

  # URI.escape
  def escape_url(reg=WWMD::ESCAPE[:url])#:nodoc:
    self.escape(reg)
  end

  def escape_xss(reg=WWMD::ESCAPE[:xss])#:nodoc:
    self.escape(reg)
  end

  def escape_default(reg=WWMD::ESCAPE[:default])
    self.escape(reg)
  end
  # URI.escape all characters in string
  def escape_all#:nodoc:
    self.escape(/.*/)
  end

  # URI.unescape
  def unescape
    URI.unescape(self)
  end

  # encode the string using Encoding.to_utf7(self,false)
  # (encode non [:alnum:] characters).  Set <tt>all</tt> true
  # to encode all characters in the string.
  def to_utf7(all=false)
    Encoding.to_utf7(self,all)
  end

    # File.dirname with a trailing slash
  def dirname
    return self if self.match(/\/$/)
    File.dirname(self) + "/"
  end

  # File.basename
  def basename
    File.basename(self)
  end

  def extname
    self.split('.').last
  end

  # return OpenSSL::Digest::MD5.new(self)
  def md5
    OpenSSL::Digest::MD5.new(self)
  end

  def sha1
    OpenSSL::Digest::SHA1.new(self)
  end

  # write string to passed filename
  # if filename is nil? will raise an error
  def write(fname=nil)
    raise "filename required" if fname.nil?
    File.write(fname,self)
    return fname
  end

  # parse passed GET param string into a form and return the FormArray object
  def to_form
    ret = Hpricot::FormArray.new
    self.split("&").each do |x|
      y = x.split("=",2)
      ret.extend!(y[0].to_s,y[1].to_s)
    end
    return ret
  end

  # create filename from url changing "/" to "_"
  def to_fn(ext=nil)
    ret = self.clip.split("/")[3..-1].join("_")
    ret += ".#{ext}" if not ext.nil?
    return ret
  end

  # html entity encode string
  #  sym = :basic :named :decimal :hexadecimal
  def eencode(sym=nil)
    sym = :named if sym.nil?
    @@he.encode(self,sym)
  end

  # decode html entities in string
  def edecode
    return @@he.decode(self)
  end

  def edecode!
    self.replace(@@he.decode(self))
  end

  # strip html tags from string
  def strip_html
    self.gsub(/<\/?[^>]*>/, "")
  end

  # check if this string is a guid
  def is_guid?
    begin
      Guid.from_s(self)
    rescue => e
      return false
    end
    return true
  end

  # return a literal regexp object for this string
  #
  # escape regexp operators
  def to_regexp
    return Regexp.new(self.gsub(/([\[\]\{\}\(\)\*\$\?])/) { |x| '\\' + x })
  end

  def head(c=5)
    return nil if c <= 0
    c -= 1
    self.split("\n")[0..c].join("\n")
  end
end

class Array
  # grep each element of an array for the passed regular expression
  # and return an Array of matches
  # (only works one deep)
  def each_grep(regex)
    ret = []
    self.each { |e| ret << e.grep(regex) }
    return ret
  end

  # join the array with "\n" and write to a file
  def to_file(filename)
    File.write(filename,self.join("\n"))
  end
end

class Hash#:nodoc:
  # no idea what I was doing here
  def to_f#:nodoc:
    self.each_key { |l| puts "#{l} = " + self[l] }
    return nil
  end
end

class File
  # write string to file
  def self.write(filename,contents)
    fout = File.open(filename,"w")
    fout.puts contents
    fout.close
  end
end
