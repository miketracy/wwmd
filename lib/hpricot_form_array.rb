#!/usr/bin/env ruby
=begin rdoc
:include: ../sig.do
This is a weird kind of data structure for no other reason than
I wanted to keep the form inputs in order when they come in.

Accessing this either as a hash or an array (but => won't work)

Some of the methods in here are kept for backward compat before the refactor
and now everything in this array should be accessed with []= and []
=end

#
module Hpricot
	class FormArray < Array

		attr_accessor :snapshot

		def initialize(fields=nil)
			if not fields.nil?
				# this first one is an array of field objects
				if fields.class == Array then
					fields.each do |f|
						name = f.get_attribute("name")
						if self.name_exists(name) then
							if f.get_attribute("type") == "hidden" then
								self.set name,f.get_value
							elsif f.get_attribute("type") == "checkbox" and f.to_html.grep(/checked/) != '' then
								self.set name,f.get_value
							end
						else
							self << [ f.get_attribute("name"),f.get_value ]
						end
					end
				elsif fields.class == Hash then
					fields.each_pair { |k,v| self.extend! k,v }
				elsif fields.class == String then
					fields.split("&").each do |f|
						self.extend!(f.split("=")[0],f.split("=")[1])
					end
				end
			end
			@snapshot = ''
		end

		# "deep enough" copy of this object to make it a real copy
		# instead of references to the arrays that already exist
		def clone
			ret = self.class.new
			self.each { |r| ret << r.clone }
			return ret
		end

		# save a snapshot of the current form values (BROKEN)
		def snap
			@snapshot = self.clone
		end

		# reset form values to the last snapshot (BROKEN)
		def reset
			self.clear
			self.snapshot.each { |k,v| self.extend!(k,v) }
		end

		def clear
			self.delete_if { |x| true }
		end

		# check if the passed name exists in the form
		def include?(key)
			self.map { |x| x.first }.flatten.include?(key)
		end

		alias name_exists include?#:nodoc:
		alias name_exists? include?#:nodoc:
		alias has_key? include?#:nodoc:

		# add key/value pairs to form
		def extend!(key,value)
			self << [key,value]
		end

		# key = Fixnum set value at index key
		# key = String find key named string and set value
		def set_value!(key,value)
			if key.class == Fixnum then
				self[key][1] = value
				return [self[key][0], value]
			end
			self.each_index do |i|
				if self[i][0] == key
					self[i] = [key,value]
				end
			end
			return [key,value]
		end

		alias_method :old_get, :[]#:nodoc:
		def [](*args)
			if args.first.class == Fixnum then
				self.old_get(args.first)
			else
				self.get_value(args.first)
			end
		end

		alias_method :old_set, :[]=#:nodoc:
		# set a key using its index, array key or extend using a new key i.e.:
		# if setting
		#  form = [['key','value'],['foo','bar']]
		#  form[0] = "newalue
		#  
		#  
		
#		def []=(*args)#:nodoc:
#			key,value = args
#			if self.map { |x| x.first }.flatten.include?(key) then
#				self.set_value!(key,value)
#			elsif key.class == Fixnum
#				self.extend!(key,value)
#			end
#		end

		alias set_value set_value!
		alias set set_value!

		def get_value(key)
			if key.class == Fixnum then
				return self[key][1]
			end
			self.each_index do |i|
				if self[i][0] == key
					return self[i][1]
				end
			end
			return nil
		end

		alias get get_value

		def setall!(value)
			self.each_index { |i| self.set_value!(i,value) }
		end

		alias setall setall!#:nodoc:
		alias set_all! setall!#:nodoc:
		alias set_all setall!#:nodoc

		# delete all key = value pairs from self where key = key
		def delete_keys!(key)
			self.reject! { |x,y| x == key }
		end

		alias delete_key! delete_keys!

		def escape_all!(reg=WWMD::ESCAPE[:url])
			return nil if reg == :none
			self.each_index { |i| self.set_value(i,self[i][1].to_s.escape(reg)) }
		end

		alias escape_all escape_all!#:nodoc:

		# unescape all form data in place
		def unescape_all!
			self.each_index { |i| self.set_value(i,self[i][1].gsub(/\+/," ").unescape) }
		end

		alias unescape_all unescape_all!#:nodoc:

		# convert form into a post parameters string
		def to_post
			ret = []
			self.each do |i|
				ret.push(i.join("="))
			end
			ret.join("&")
		end

		# convert form into a get parameters string
		def to_get
			ret = []
			self.each do |i|
				ret.push(i.join("="))
			end
			ret = ret.join("&")
			return "?" + ret.to_s
		end

		# IRB: puts the form in human readable format
		# if you <tt>form.show(true)</tt> it will show unescaped values
		def show(unescape=false)
			if unescape then
				self.each_index { |i| puts i.to_s + " :: " + self[i][0].to_s + " = " + self[i][1].to_s.unescape }
			else
				self.each_index { |i| puts i.to_s + " :: " + self[i][0].to_s + " = " + self[i][1].to_s }
			end
			return true
		end

		# meh
		def add_viewstate#:nodoc:
			self.insert(0,[ "__VIEWSTATE","" ])
			self.insert(0,[ "__EVENTARGUMENT","" ])
			self.insert(0,[ "__EVENTTARGET","" ])
		end

		alias add_state add_viewstate#:nodoc:

		# remove form elements with null values
		def remove_nulls
			self.delete_if { |x| x[1].to_s.empty? || x[1].nil? }
		end

		# dump a web page containing a csrf example of the current FormArray
		def to_csrf(action,escape=WWMD::ESCAPE[:default])
			ret = ""
			ret << "<html><body>\n"
			ret << "<form method='post' id='mtsotest' name='mtsotest' action='#{action}'>\n"
			self.each_index do |i|
		        ret << "<input name='#{self[i][0].to_s.escape(escape)}' type='hidden' value='#{self[i][1].to_s.escape(escape)}' />\n"
			end
			ret << "</form>\n"
			ret << "<script>document.mtsotest.submit()</script>\n"
			ret << "</body></html>\n"
			return ret
		end

		def burpify
			foo = self.clone
			foo.each_index do |i|
				next if foo[i][0] =~ /^__/
				foo.set_value!(i,"#{foo.get_value(i)}" + "\302\247" + "\302\247")
			end
			system("echo '#{foo.to_post}' | pbcopy")
			return foo
		end

		def fingerprint
			return self.map { |k,v| k }.sort.to_s.md5
		end

		alias fp fingerprint
	end
end
