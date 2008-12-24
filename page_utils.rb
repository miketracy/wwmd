#!/usr/bin/env ruby
#:include:sig.do

# everything in here needs a rework

module WWMD
	class WWMDUtils

		# return fq link from passed relative uri
		def self.fq_link(root,eff,link)
			return link if link.match(/^http.?:/)
			# this might actually be the solution?!?!?
			root = eff.split("/")[0..2].join("/") if root.nil?
			return (root + link) if link.match(/^\//)
			# !!!! this is incredibly hacky and needs to be fixed
			begin
				has_ext = File.basename(eff).split(".").size > 1
				base = root + "/"
				base = File.dirname(eff) + "/" if not eff.nil? and has_ext
				return self.fix_dotdot(base + link)
			rescue => e
#				putw "WARN: ERROR parsing page"
				return "ERROR"
			end
		end

		# change // to / (outside http.*://)
		def self.fix_slashslash(url)
			url.gsub!(/\/\//,"/")
			url.gsub!(/:\//,"://")
			return url
		end

		# fix traversal urls
		def self.fix_dotdot(url)
			tmp = url.split(/\//) # array containing the url
			ret = Array.new       # accumulator for return url
			tmp.each_index do |i|
				# iterate over each bit of the url
				# if we get "..", delete the last value of ret and skip
				if tmp[i] == ".."
					putw "ERROR: cannot convert #{url}" and returl nil if i == 0
					ret.delete_at(-1) if i != 3 # skip if we are already at the root
				else
					ret << tmp[i]
				end
			end
			ret = ret.join("/")
			# !!!! this is incredibly hacky and needs to be fixed
#			ret.gsub!(/[^:](\/\/)/,"/")
			return self.fix_slashslash(ret)
		end

		def self.header_array_from_file(filename)
			ret = Hash.new
			File.readlines(filename).each do |line|
				a = line.chomp.split(/\t/,2)
				ret[a[0]] = a[1]
			end
			return ret
		end

		def self.array_to_form(arr)
			ret = []
			arr.each do |i|
				ret.push(i.join("="))
			end
			ret.join("&")
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
