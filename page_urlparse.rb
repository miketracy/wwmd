module WWMD
	# this is pretty awful but yay for experiments in re-inventing the wheel
	class URLParse
		HANDLERS = [:https,:http,:ftp,:file]
		attr_reader :type
		attr_reader :host
		attr_reader :path
		attr_reader :script
		attr_reader :base
		attr_reader :path

		def initialize()
		end

		def parse(base,path)
			@base = base
			@path = path
			@type = @location = nil
			@base += "/" if (!@base.has_ext? || @base.split("/").size == 3)
			return path if self.has_location?
			@path = hash_me.join("/")
			return "#{@type}://#{@location}/#{@path}"
		end

		def hash_me
			@type,tpath = @base.split(":",2)
			a_path = tpath.dirname.split("/").reject { |x| x.empty? }
			@location = a_path.shift
			a_path = [] if !(path =~ (/^\//)).nil?
			b_path = (a_path + path.split("/").reject { |x| x.empty? }).flatten
			c_path = []
			b_path.each do |x|
				(c_path.pop;next) if x == ".."
				next if x == "."
				c_path << x
			end
			return c_path
		end

		def has_location?
			return true if HANDLERS.include?(path.split(":").first.downcase.to_sym)
		end

	end
end

class String
	def has_ext? #:nodoc:
		return false if self.basename.split(".",2)[1].empty?
		return true
	end
end
