#!/usr/bin/env ruby
#:include:sig.do

module WWMD
	attr_accessor :curl_object
	attr_accessor :body_data
	attr_accessor :post_data
	attr_accessor :header_data
	attr_accessor :use_referer
	attr_accessor :form          # Hpricot::Form object
	attr_reader   :last_error
	attr_reader   :links         # array of links (urls)
	attr_reader   :jlinks        # array of included javascript files
	attr_reader   :forms         # array of Hpricot::Form objects
	attr_reader   :fields        # array of Hpricot::Field objects
	attr_reader   :spider        # spider object
	attr_reader   :scrape        # scrape object
	attr_reader   :comments
	attr_reader   :last_url
	attr_reader   :h_response_code

	attr_accessor :base_url      # needed to properly munge relative urls into fq urls
	attr_accessor :logged_in     # are we logged in?

	attr_accessor :opts
	attr_accessor :inputs

	# WWMD::Page is an extension of a Curl::Easy object which provides methods to
	# enhance and ease the performance of web application penetration testing.
	class Page

		def initialize(opts={})
			@opts = opts.clone
			DEFAULTS.each_key { |k| @opts[k] = opts[k] || DEFAULTS[k] }
			@spider = Spider.new(opts)
			@scrape = Scrape.new
			if opts.empty? then
				puts "Page initialized without opts"
				@scrape.warn = false
			end
			@inputs = Inputs.new(self)
			@logged_in = false
			@use_referer = false
			@body_data = ""
			@post_data = ""
			@comments = []
			@header_data = FormArray.new

			@curl_object = Curl::Easy.new
			@opts.each do |k,v|
				next if !(@curl_object.methods.include?("#{k}="))
				next if k == :proxy_url
				@curl_object.send("#{k}=",v)
			end
			@curl_object.on_body   { |data| self._body_cb(data) }
			@curl_object.on_header { |data| self._header_cb(data) }

			# cookies?
			@curl_object.enable_cookies = @opts[:enable_cookies]
			if @curl_object.enable_cookies? then
				@curl_object.cookiejar = @opts[:cookiejar] || "./__cookiejar"
			end

			#proxy?
			@curl_object.proxy_url = @opts[:proxy_url] if @opts[:use_proxy]
		end

#:section: Heavy Lifting

		# set reporting data for the page
		#
		# Scan for comments, anchors, links and javascript includes and
		# set page flags.  The heavy lifting for parsing is done in the
		# scrape class.
		#
		# returns: <tt>array [ code, page_status, body_data.size ]</tt>
		def set_data
			# reset scrape and inputs object
			# transparently gunzip
			begin
				io = StringIO.new(self.body_data)
				gz = Zlib::GzipReader.new(io)
				self.body_data.replace(gz.read)
			rescue => e
			end

			@scrape.reset(self.body_data)
			@inputs.set

			@comments = @scrape.for_comments
			# remove comments that are css selectors for IE silliness
			@comments.reject! do |c|
				c =~ /\[if IE\]/ ||
				c =~ /\[if IE \d/ ||
				c =~ /\[if lt IE \d/
			end
			@links = @scrape.for_links.map do |url|
				WWMDUtils.fq_link(self.opts[:base_url],self.last_effective_url,url)
			end
			@jlinks = @scrape.for_javascript_links
			@forms = []
			self.search("//form").each { |f| @forms << Hpricot::Form.new(f) }
			@spider.add(self.last_effective_url,@links)
			return [self.code,self.page_status,self.body_data.size]
		end

		# clear self.body_data and self.header_data
		def clear_data
			return false if self.opts[:parse] = false
			@body_data = ""
			@header_data.clear
			@last_error = nil
		end

		# override Curl::Easy.perform to perform page actions,
		#  call <tt>self.set_data</tt>
		#
		# returns: <tt>array [ code, page_status, body_data.size ]</tt>
		#
		# don't call this directly if we are in console mode
		# use get and submit respectively for GET and POST
		def perform
			self.clear_data
			@last_url = self.url
			self.headers["Referer"] = self.cur if self.use_referer
			begin
				@curl_object.perform
			rescue => e
				@last_error = e
				puts "WARN: #{e.class}" if !(e.class =~ /Curl::Err/).nil?
				self.logged_in = false
			end
			self.set_data
			return [self.code,self.page_status,self.body_data.size]
		end

		# replacement for Curl::Easy.http_post
		#
		# post the form attempting to remove curl supplied headers (Expect, X-Forwarded-For
		# call <tt>self.set_data</tt>
		#
		# if passed a regexp, escape values in the form using regexp before submitting
		# if passed nil for the regexp arg, the form will not be escaped
		# default: WWMD::ESCAPE[:url]
		#
		# returns: <tt>array [ code, body_data.size ]</tt>
		def submit(iform=nil,reg=WWMD::ESCAPE[:default])
=begin
	this is just getting worse and worse
=end
			if iform.class == "Symbol" then
				reg = iform
				iform = nil
			end
			self.clear_data
			self.clear_header("Expect")
			self.clear_header("X-Forwarded-For")
			self.clear_header("Content-length")
			self.headers["Referer"] = self.cur if self.use_referer
			if iform == nil
				if not self.form.empty? then
					sform = self.form.clone
				else
					return "no form provided"
				end
			else
				sform = iform.clone             # clone the form so that we don't change the original
			end
			sform.escape_all!(reg)
			if sform != '' then
				self.http_post(sform.to_post)
				self.post_data = sform.to_post
			else
				self.http_post('')
			end
			begin
				self.set_data
			rescue => e
				STDERR.puts "FATAL: could not parse page"
			end
			return [self.code, self.body_data.size]
		end

		# submit a form using POST string
		def submit_string(post_string)
			self.clear_data
			self.http_post(post_string)
			self.set_data
			if self.ntlm? then
				putw "WARN: this page requires NTLM Authentication"
				putw "WARN: use ntlm_get instead of get"
			end
			return [self.code, self.body_data.size]
		end

		# override for Curl::Easy.perform
		#
		# returns: <tt>array [ code, body_data.size ]</tt>
		def get(url=nil)
			self.url = url if not url.nil?
			self.url = url.to_s if url.kind_of?(Symbol)
			self.perform
			if self.ntlm? then
				putw "WARN: this page requires NTLM Authentication"
				putw "use ntlm_get instead of get"
			end
			self.set_data
			return [self.code, self.body_data.size]
		end

=begin
# Curl::Easy doesn't do other verbs.  Looking into RFuzz::HttpClient and Net/HTTP
#		def head(url=nil)
#			self.url = url if not url.nil?
#			self.http_head
#			self.set_data
#			return [self.code, self.header_data.size]
#		end
#
#		def put(path,data)
#			hobj = Net::HTTP.new
#			ret = hobj.send_request('PUT',path,data)
#			putx ret
#			self.url = url if not url.nil?
#			self.http_put
#			self.set_data
#			return [self.code, self.body.size]
#		end
=end

#:section: Reporting helper methods
# These are methods that generate data for a parsed page

		# return text representation of page code
		#
		# override with specific statuses in helper depending on page text
		# etc to include statuses outside 200 = OK and other = ERR
		def page_status
			return "ERR" if self.response_code != 200
			return "OK"
		end

		alias status page_status#:nodoc:

		# return value of @logged_in
		def logged_in?
			return @logged_in
		end

		# return a string of flags:
		# Ll:: page has links
		# Jj:: page has javascript includes
		# Ff:: page has forms
		#--
		# Ee:: page has form fields
		# Pp:: page has GET params
		#++
		# Cc:: page has comments
		def report_flags
			self.has_links?      ? ret  = "L" : ret  = "l"
			self.has_jlinks?     ? ret += "J" : ret += "j"
			self.has_form?       ? ret += "F" : ret += "f"
			self.has_comments?   ? ret += "C" : ret += "c"
			return ret
		end

		# return page size in bytes
		def size
			return self.body_data.size
		end

		# does this page have links?
		def has_links?
			return false if @links.empty?
			return true
		end

		# does this page have form(s)?
		def has_form?
			return false if @forms.size < 1
			return true
		end

		# does this page have javascript includes?
		def has_jlinks?
			begin
				return false if @jlinks.empty?
			rescue => e
				putw "WARN: error gtting javascript #{e.inspect}"
				return false
			end
			return true
		end

		def has_comments?
			begin
				return false if @comments.empty?
			rescue => e
				putw "WARN: error getting comments #{e.inspect}"
				return false
			end
			return true
		end

		# YYYY: not implemented
		#
		# does this page have GET params?
		def has_params?
			return false
		end

#:section: Other methods

		def all_tags#:nodoc:
			return self.search("//").map do |x|
				x if x.class == Hpricot::Elem
			end.reject! do |x|
				x.nil?
			end.map do |x|
				x.name
			end
		end

		# return MD5 for DOM fingerprint
		# take all tag names in page.to_s.md5
		def fingerprint
			self.all_tags.to_s.md5
		end
		alias fprint fingerprint

		# set link using an integer link from self.report
		#--
		# NOTE: I always use page.get(page.l(1)) anyway.
		#++
		def set_link(index)
			self.url = @links[index]
		end

		# return link at index from @links array
		def get_link(index)
			@links[index]
		end

		alias l get_link#:nodoc:

		# alias for body_data
		def raw
			self.body_data
		end

		# alias for last_effective_url
		def current_url
			self.last_effective_url
		end

		alias current current_url
		alias cur current_url

		# the last http response code
		def code
			self.response_code # .to_s
		end

#:section: Parsing convenience methods
# methods that help parse and find information on a page including
# access to forms etc.

		# grep for regexp and remove leading whitespace
		def grep(reg)
			self.body_data.grep(reg).collect! { |i| i.gsub(/^\s+/, "") }
		end

		# return this page's form (at index id) as a FormArray
		def get_form(id=nil)
			id = 0 if id.nil?
			return nil if forms.empty?
			@forms[id].to_form_array
		end

		# return the complete url to the form action on this page
		def action(id=nil)
			id = 0 if id.nil?
			act = self.forms[id].action
			if act =~ /^http.?:/ then
				return act
			end
			if act.match(/^\//) then
				if self.opts[:base_url].nil? then
					rurl = self.last_effective_url.split("/")[0..3].join("/")
				else
					rurl = self.opts[:base_url] + "/"
				end
			else
				rurl = self.last_effective_url + "/"
				rurl = self.last_effective_url.dirname if self.opts[:base_url] != self.last_effective_url
			end
			murl = act.gsub(/^\//,'')
			ret =  WWMDUtils.fix_dotdot(rurl + murl)
			return ret
		end

		# return an array of Hpricot::Element objects for an xpath search
		def search(xpath)
			return Hpricot(self.body_data).search(xpath)
		end

		alias get_tags search#:nodoc:

		# return an array of inner_html for each <script> tag encountered
		def dump_scripts
			self.get_tags("//script").map { |s| s.inner_html if s.inner_html.strip != '' }
		end

		alias scripts dump_scripts

#:section: Input and Output Helpers

		# set self.opts[:base_url]
		def setbase(url=nil)
			return nil if url.nil?
			self.opts[:base_url] = url
		end

		# return md5sum for self.body_data
		def md5
			return self.body_data.md5
		end

		# write self.body_data to file
		def write(filename)
			File.write(filename,self.body_data)
			return "wrote to " + filename
		end

		# read self.body_data from file
		def read(filename)
			self.body_data = File.read(filename)
			self.set_data
		end

		# hexdump self.body_data
		def hexdump
			self.body_data.hexdump
		end

		# does this response have SET-COOKIE headers?
		def set_cookies?
			ret = []
			self.header_data.each do |x|
				if x[0].upcase == "SET-COOKIE" then
					ret << x[1]
				end
			end
			ret
		end

#:section: Data callbacks and method_missing

		# callback for <tt>self.on_body</tt>
		def _body_cb(data)
			@body_data << data if not data.nil?
			return data.length.to_i
		end

		# callback for <tt>self.on_header</tt>
		def _header_cb(data)
			myArr = Array.new(data.split(":",2))
			@header_data.extend! myArr[0].to_s.strip,myArr[1].to_s.strip
			return data.length.to_i
		end

		# send methods not defined here to <tt>@curl_object</tt>
		def method_missing(methodname, *args)
			@curl_object.send(methodname, *args)
		end

	end
end
