module WWMD
  class WWMDUtils

    def self.header_array_from_file(filename)
      ret = Hash.new
      File.readlines(filename).each do |line|
        a = line.chomp.split(/\t/,2)
        ret[a[0]] = a[1]
      end
      return ret
    end

    def self.ranstr(len=8,digits=false)
      chars = ("a".."z").to_a
      chars += ("0".."9").to_a if digits
      ret = ""
      1.upto(len) { |i| ret << chars[rand(chars.size-1)] }
      return ret
    end

    def self.rannum(len=8,hex=false)
      chars = ("0".."9").to_a
      chars += ("A".."F").to_a if hex
      ret = ""
      1.upto(len) { |i| ret << chars[rand(chars.size-1)] }
      return ret
    end

  end
end
