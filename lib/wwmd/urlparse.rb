require 'htmlentities'
require 'wwmd/class_extensions'
module WWMD

  # yay for experiments in re-inventing the wheel
  class URLParse
    HANDLERS = [:https,:http,:ftp,:file]
    attr_reader :proto,:location,:path,:script,:rpath,:params,:base_url,:fqpath

    def initialize(*args)
      # nothing to see here, move along
    end

    def parse(*args)
      if args.size == 1
        base = ""
        actual = args.shift
      else
        base = args.shift
        actual = args.shift
      end
      @proto = @location = @path = @script = @rpath = nil
      @base = base.to_s
      @actual = actual
      if self.has_proto?
        @base = @actual
        @actual = ""
      end
# does this work for http://location/?  probably not
      @base += "/" if (!@base.has_ext? || @base.split("/").size == 3)
      @rpath = make_me_path.join("/")
      @rpath += "?#{@params}" if @params
      @path = "/" + @rpath
      if @rpath.has_ext?
        @path = "/" + @rpath.dirname
        @script = @rpath.basename.clip
      end
      @script = "" if @script.nil?
      begin
        @base_url = @proto + "://" + @location
      rescue => e
        return false
        raise e
        dbg = WWMD.debug
        WWMD.debug = true
        putd "ERROR in urlparse TRACE:"
        pp *args
        putd @proto
        putd @base
        putd @actual
        putd @location
        WWMD.debug = dbg
        raise e
      end
      @fqpath = @path + @script
      self
    end

    def make_me_path
      @proto,tpath = @base.split(":",2)
      tpath ||= ""
      @params = tpath.clop
      tpath = tpath.clip
      if @actual.empty?
        a_path = tpath.split("/").reject { |x| x.empty? }
      else
        a_path = tpath.dirname.split("/").reject { |x| x.empty? }
      end
      @location = a_path.shift
      if @actual.clop
        @params = @actual.clop
        @actual = @actual.clip
      end
      a_path = [] if (@actual =~ (/^\//))
      b_path = @actual.split("/").reject { |x| x.empty? }
      a_path.pop if (a_path[-1] =~ /^\?/).kind_of?(Fixnum) && !b_path.empty?
      c_path = (a_path + @actual.split("/").reject { |x| x.empty? }).flatten
      d_path = []
      c_path.each do |x|
        (d_path.pop;next) if x == ".."
        next if (x == "." || x =~ /^\?/)
        d_path << x
      end
      return d_path
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
  def has_ext? #:nodoc:
    return false if self.basename.split(".",2)[1].empty?
    return true
  end
end
