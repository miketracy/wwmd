require 'htmlentities'

=begin rdoc
let's re-open everything!
=end

require 'uri'

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
    [24, 16, 8, 0].map { |b| (self >> b) & 255 }.join('.')
  end

  # integer to mac address [uses ':' as delimiter]
  def int_to_mac
    [40,32,24,16,8,0].map { |b| ((self >> b) & 255).to_s(16).rjust(2,"0") }.join(":")
  end
end

class String

  def strip_up
    self.gsub(/[^\x20-\x7e,\n]/,"").gsub(/^\n/,"")
  end

  # ip address to int
  def ip_to_int
    self.split('.').inject(0) { |a,e| (a << 8) + e.to_i }
  end

  # mac address to int [uses ':' as delimiter]
  def mac_to_int
    self.split(':').inject(0) { |a,e| (a << 8) + e.to_i(16) }
  end

  # return true or false for <tt>string.match</tt>  
  def contains?(rexp)
    return !self.match(rexp).nil?
  end

  # strip the string and return true if empty
  def empty?
    return self.strip == ''
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

  def clopa
    return [self.clip,self.clop]
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

  # write string to passed filename
  # if filename is nil? will raise an error
  def write(fname=nil)
    raise "filename required" if fname.nil?
    File.write(fname,self)
    return fname
  end

  # parse passed GET param string into a form and return the FormArray object
  def to_form
    if self.split("\n").size > 1
      return self.to_form_from_show
    end
    ret = FormArray.new
    self.split("&").each do |x|
      y = x.split("=",2)
      ret.extend!(y[0].to_s,y[1].to_s)
    end
    return ret
  end

  def to_form_from_show
    self.split("\n").map { |a|
      key,val = a.split("=",2)
      key = key.split(" ")[-1]
      val = val.strip if val
      ["#{key}=#{val}"]
    }.join("&").to_form.squeeze_keys!
  end

  def mform
    return self.gsub("\n","").to_form
  end

  def to_form_from_req
#    self.split("\x0d\x0a\x0d\x0a")[1].to_form
    self.split("\n\n")[1].to_form
  end
  alias_method :to_ffr, :to_form_from_req

  # create filename from url changing "/" to "_"
  def to_fn(ext=nil)
    ret = self.clip.split("/")[3..-1].join("_")
    ret += ".#{ext}" if not ext.nil?
    return ret
  end

  # strip html tags from string
  def strip_html
    self.gsub(/<\/?[^>]*>/, "")
  end

  # range or int
  def head(c=5)
    if c.kind_of?(Range) then
      range = c
    else
      range = (0..(c - 1))
    end
    self.split("\n")[range].join("\n")
  end

  # return a literal regexp object for this string
  #
  # escape regexp operators
  def to_regexp
    return Regexp.new(self.gsub(/([\[\]\{\}\(\)\*\$\?])/) { |x| '\\' + x })
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

  def md5
    Digest::MD5.digest(self).hexify
  end

  def sha1
    Digest::SHA1.digest(self).hexify
  end

  def sha256
    Digest::SHA256.digest(self).hexify
  end

  def sha512
    Digest::SHA512.digest(self).hexify
  end

  def pbcopy
    IO.popen('pbcopy', 'r+') { |c| c.print self }
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

class File
  # write string to file
  def self.write(filename,contents)
    fout = File.open(filename,"w")
    fout.print contents
    fout.close
  end
end
