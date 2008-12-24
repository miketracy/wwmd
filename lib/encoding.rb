#!/usr/bin/env ruby
=begin rdoc
:include:../sig.do

Place methods to character encodings here
=end

module WWMD
	# This is where character encodings should go as singletons
	# to be used as mixins for the String class
	class Encoding

		# Helper for String.to_utf7 mixin
		# (complete hack but it works)
		#
		# if all=true, encode all characters.
		# if all.class=Regexp encode only characters in the passed
		# regular expression else default to /[^0-9a-zA-Z]/
		#
		# used by:
		#	String.to_utf7
		#	String.to_utf7!
		def self.to_utf7(str,all=nil)
			if all.kind_of?(Regexp) then
				reg = all
			elsif all.kind_of?(TrueClass) then
				reg = ESCAPE[:all]
			else
				reg = ESCAPE[:nalnum] || /[^a-zA-Z0-9]/
			end
			puts reg.inspect
			ret = ''
			str.each_byte do |b|
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
