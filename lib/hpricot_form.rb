#!/usr/bin/env ruby
=begin rdoc
:include:../sig.do

mixins for the Hpricot module
  Form
  Field
  FormArray
=end

module Hpricot
	# == original author
	#
	#  Chew Choon Keat <choonkeat at gmail>
	#  http://blog.yanime.org/
	#  19 July 2006
	#
	# updated by mtracy at matasano.com for use with WWMD
	#
	class Form
		attr_accessor :hdoc
		attr_accessor :fields
		attr_accessor :formtag

		def initialize(doc)
			@hdoc = doc
			@formtag = @hdoc.search("//form")
		end

		def method_missing(*args)
			hdoc.send(*args)
		end

		def fields
			@fields ||= (hdoc.search("//input[@name]") + hdoc.search("//select[@name]") + hdoc.search("//textarea")).collect {|x| Field.new(x)}
		end

		def field_names
			fields.collect{ |x| x.get_attribute("name") }
		end

		def action
			return self.get_attribute("action")
		end

		def report
			puts "action = #{self.action}"
			self.fields.each { |field| puts field.to_text }
			return nil
		end

		alias show report

		def to_form_array
			FormArray.new(self.fields)
#			ret = FormArray.new(self.fields)
#			self.fields.each { |f| ret << [ f.get_attribute("name"),f.get_value ] }
#			return ret
		end

		def to_array
			self.to_form_array
		end
	end

	class Field < Form
		def value
			self._value.nil? ? self.get_attribute("value") : self._value
#			self.get_attribute("value").nil? ? self.value : self.get_attribute("value")
		end

		alias get_value value #:nodoc:
		alias fvalue value #:nodoc:

		def fname
			self.get_attribute('name')
		end

		def ftype
			self.get_attribute('type')
		end

		def _value
			# selection (array)
			ret = hdoc.search("//option[@selected]").collect { |x| x.get_attribute("value") }
			case ret.size
			when 0
				if name == "textarea"
					hdoc.innerHTML
				else
					hdoc.get_attribute("value") if (hdoc.get_attribute("checked") || !hdoc.get_attribute("type") =~ /radio|checkbox/)
				end
			when 1
				ret.first
			else
				ret
			end
		end

		def to_arr
			return [self.name, self.ftype, self.fname, self.fvalue]
		end

		def to_text
			return "tag=#{self.name} type=#{self.ftype} name=#{self.fname} value=#{self.fvalue}"
		end

	end
end
