module WWMD
  attr_accessor :curl_object
  attr_accessor :body_data
  attr_accessor :post_data
  attr_accessor :header_data
  attr_accessor :use_referer
  attr_reader   :forms
  attr_reader   :last_error
  attr_reader   :links         # array of links (urls)
  attr_reader   :jlinks        # array of included javascript files
  attr_reader   :spider        # spider object
  attr_reader   :scrape        # scrape object
  attr_reader   :urlparse      # urlparse object
  attr_reader   :comments

  attr_accessor :base_url      # needed to properly munge relative urls into fq urls
  attr_accessor :logged_in     # are we logged in?

  attr_accessor :opts
  attr_accessor :inputs

  # WWMD::Page is an extension of a Curl::Easy object which provides methods to
  # enhance and ease the performance of web application penetration testing.
  class Page

    def initialize(opts={})
      @opts = opts.clone
      DEFAULTS.each { |k,v| @opts[k] = v if not opts[k] }
      @spider = Spider.new(opts)
      @scrape = Scrape.new
      @base_url ||= opts[:base_url]
      @scrape.warn = opts[:scrape_warn] if opts[:scrape_warn]
      if opts.empty?
        putw "Page initialized without opts"
        @scrape.warn = false
      end
      @urlparse = URLParse.new()
      @inputs = Inputs.new(self)
      @logged_in = false
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
      if @curl_object.enable_cookies?
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
        @urlparse.parse(self.last_effective_url,url).to_s
      end
      @jlinks = @scrape.for_javascript_links
      @forms = []
      self.search("//form").each { |f| @forms << Form.new(f) }
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
      self.headers["Referer"] = self.cur if self.use_referer
      begin
        @curl_object.perform
      rescue => e
        @last_error = e
        putw "WARN: #{e.class}" if e.class =~ /Curl::Err/
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
      if iform.class == "Symbol"
        reg = iform
        iform = nil
      end
      self.clear_data
      ["Expect","X-Forwarded-For","Content-length"].each { |s| self.clear_header(s) }
      self.headers["Referer"] = self.cur if self.use_referer
      if iform == nil
        if not self.form.empty?
          sform = self.form.clone
        else
          return "no form provided"
        end
      else
        sform = iform.clone             # clone the form so that we don't change the original
      end
      sform.escape_all!(reg)
      if sform.empty?
        self.http_post('')
      else
        self.http_post(self.post_data = sform.to_post)
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
      if self.ntlm?
        putw "WARN: this page requires NTLM Authentication"
        putw "WARN: use ntlm_get instead of get"
      end
      return [self.code, self.body_data.size]
    end

    # override for Curl::Easy.perform
    #
    # if the passed url string doesn't contain an fully qualified
    # path, we'll guess and prepend opts[:base_url]
    #
    # returns: <tt>array [ code, body_data.size ]</tt>
    def get(url=nil)
      self.url = @urlparse.parse(self.opts[:base_url],url).to_s if url
      self.perform
      if self.ntlm?
        putw "WARN: this page requires NTLM Authentication"
        putw "use ntlm_get instead of get"
      end
      self.set_data
      return [self.code, self.body_data.size]
    end

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

    alias_method :status, :page_status#:nodoc:

    # return value of @logged_in
    def logged_in?
      return @logged_in
    end

    # return a string of flags:
    # Ll links
    # Jj javascript includes
    # Ff forms
    # Cc comments
    def report_flags
      self.has_links?      ? ret  = "L" : ret  = "l"
      self.has_jlinks?     ? ret += "J" : ret += "j"
      self.has_form?       ? ret += "F" : ret += "f"
      self.has_comments?   ? ret += "C" : ret += "c"
      return ret
    end

    def has_links?;    return !@links.empty?;     end
    def has_jlinks?;   return !@jlinks.empty?;    end
    def has_form?;     return !(@forms.size < 1); end
    def has_comments?; return !@comments.empty?;  end

    # return page size in bytes
    def size
      return self.body_data.size
    end

#:section: Other methods

    def all_tags#:nodoc:
      return self.search("*").map { |x| x.name }
    end

    # return MD5 for DOM fingerprint
    # take all tag names in page.to_s.md5
    def fingerprint
      self.all_tags.to_s.md5
    end
    alias_method :fp, :fingerprint #:nodoc:

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

    alias_method :link, :get_link #:nodoc:
    alias_method :l, :get_link #:nodoc:

    # alias_method for body_data
    def raw
      self.body_data
    end

    # alias_method for last_effective_url
    def current_url
      self.last_effective_url
    end

    alias_method :current, :current_url
    alias_method :cur, :current_url

    # the last http response code
    def code
      self.response_code # .to_s
    end

#:section: Parsing convenience methods
# methods that help parse and find information on a page including
# access to forms etc.

    # grep for regexp and remove leading whitespace
    def grep(reg)
      self.body_data.grep(reg).map { |i| i.gsub(/^\s+/, "") }
    end

    # return this page's form (at index id) as a FormArray
    def get_form(id=nil)
      id = 0 if not id
      return nil if forms.empty?
      @forms[id].to_form_array
    end

    # return the complete url to the form action on this page
    def action(id=nil)
      id = 0 if not id
      act = self.forms[id].action
      return self.last_effective_url if (act.nil? || act.empty?)
      return @urlparse.parse(self.last_effective_url,act).to_s
    end

    # return an array of Element objects for an xpath search
    def search(xpath)
      self.scrape.hdoc.search(xpath)
    end

    # return an array of inner_html for each <script> tag encountered
    def dump_scripts
      self.get_tags("//script").map { |s| s.inner_html if s.inner_html.strip != '' }
    end

    alias_method :scripts, :dump_scripts

#:section: Input and Output Helpers

    # set self.opts[:base_url]
    def setbase(url=nil)
      return nil if not url
      self.opts[:base_url] = url
      self.base_url = url
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

    # does this response have SET-COOKIE headers?
    def set_cookies?
      ret = []
      self.header_data.each do |x|
        if x[0].upcase == "SET-COOKIE"
          ret << x[1]
        end
      end
      return ret
    end

    def time
      self.total_time
    end

#:section: Data callbacks and method_missing

    # callback for <tt>self.on_body</tt>
    def _body_cb(data)
      @body_data << data if data
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
