require 'htmlentities'
require 'wwmd/class_extensions'
module WWMD

  class URLParse
    HANDLERS = [:https,:http,:ftp,:file]
    attr_reader :proto,:location,:path,:script,:rpath,:params,:base_url,:fqpath

    def initialize(*args)
      # nothing to see here, move along
    end

    def parse(*args)
      if args.size == 1
        base = ""
        actual = args.shift.to_s.strip
      else
        base = args.shift.to_s.strip
        actual = args.shift.to_s.strip
      end
      if actual.has_proto?
        url = actual
      else
        url = base        
        url += "/" unless (base =~ /\/\z/ || actual =~ /\A\// || actual.empty?)
        url += actual
      end
      begin
        return URI.parse(url).to_s
      rescue => e
        STDERR.puts "WARN: #{e}"
        return nil
      end
    end

    def has_proto?
      begin
        return true if HANDLERS.include?(@actual.split(":").first.downcase.to_sym)
      rescue
        return false
      end
    end

    def to_s
      return "#{@proto}://#{@location}/#{rpath}"
    end
  end
end

class String
  HANDLERS = [:https,:http,:ftp,:file]
  def has_proto?
    begin
      return true if HANDLERS.include?(self.split(":").first.downcase.to_sym)
    rescue
      return false
    end
  end

  def has_ext? #:nodoc:
    return false if self.basename.split(".",2)[1].empty?
    return true
  end
end
