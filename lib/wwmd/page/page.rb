module WWMD
  # WWMD::Page is an extension of a Curl::Easy object which provides methods to
  # enhance and ease the performance of web application penetration testing.
  class Page
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

    attr_reader   :header_file

    attr_accessor :base_url      # needed to properly munge relative urls into fq urls
    attr_accessor :logged_in     # are we logged in?

    attr_accessor :opts
    attr_accessor :inputs


    include WWMDUtils

    def inspect
      # hack
      return "Page"
    end

    def initialize(opts={}, &block)
      @opts = opts.clone
      DEFAULTS.each { |k,v| @opts[k] = v unless opts[k] }
      @spider = Spider.new(opts)
      @scrape = Scrape.new
      @base_url ||= opts[:base_url]
      @scrape.warn = opts[:scrape_warn] if !opts[:scrape_warn].nil? # yeah yeah... bool false
      @urlparse = URLParse.new()
      @inputs = Inputs.new(self)
      @logged_in = false
      @body_data = ""
      @post_data = ""
      @comments = []
      @header_data = FormArray.new
      @header_file = nil

      @curl_object = Curl::Easy.new
      @opts.each do |k,v|
        next if k == :proxy_url
        self.instance_variable_set("@#{k.to_s}".intern,v)
        if (@curl_object.methods.include?("#{k}="))
          @curl_object.send("#{k}=",v)
        end
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
      instance_eval(&block) if block_given?
      if opts.empty? && @scrape.warn
        putw "Page initialized without opts"
        @scrape.warn = false
      end

      if @header_file
        begin
          headers_from_file(@header_file)
          @curl_object.enable_cookies = false
        rescue => e
          puts "ERROR: #{e}"
        end
      end
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

      # remove comments that are css selectors for IE silliness
      @comments = @scrape.for_comments.reject do |c|
        c =~ /\[if IE\]/ ||
        c =~ /\[if IE \d/ ||
        c =~ /\[if lt IE \d/
      end
      @links = @scrape.for_links.map do |url|
        @urlparse.parse(self.last_effective_url,url).to_s
      end
      @jlinks = @scrape.for_javascript_links
      @forms = @scrape.for_forms
      @spider.add(self.last_effective_url,@links)
      return [self.code,self.body_data.size]
    end

    # clear self.body_data and self.header_data
    def clear_data
      return false if self.opts[:parse] = false
      @body_data = ""
      @post_data = nil
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
      end
      self.set_data
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
    ## this is just getting worse and worse
      if iform.class == "Symbol"
        reg = iform
        iform = nil
      end
      self.clear_data
      ["Expect","X-Forwarded-For","Content-length"].each { |s| self.clear_header(s) }
      self.headers["Referer"] = self.cur if self.use_referer
      unless iform
        unless self.form.empty?
          sform = self.form.clone
        else
          return "no form provided"
        end
      else
        sform = iform.clone             # clone the form so that we don't change the original
      end
      sform.escape_all!(reg)
      self.url = sform.action if sform.action
      if sform.empty?
        self.http_post('')
      else
        self.http_post(self.post_data = sform.to_post)
      end
      self.set_data
    end

    # submit a form using POST string
    def submit_string(post_string)
      self.clear_data
      self.http_post(post_string)
      putw "WARN: authentication headers in response" if self.auth?
      self.set_data
    end

    # override for Curl::Easy.perform
    #
    # if the passed url string doesn't contain an fully qualified
    # path, we'll guess and prepend opts[:base_url]
    #
    # returns: <tt>array [ code, body_data.size ]</tt>
    def get(url=nil,parse=true)
      self.clear_data
      self.headers["Referer"] = self.cur if self.use_referer
      if !(url =~ /[a-z]+:\/\//) && parse
        self.url = @urlparse.parse(self.base_url,url).to_s if url
      elsif url
        self.url = url
      end
      self.http_get
      putw "WARN: authentication headers in response" if self.auth?
      self.set_data
    end

    # GET with params and POST it as a form
    def post(url=nil)
      ep = url.clip
      self.url = @urlparse.parse(self.opts[:base_url],ep).to_s if ep
      form = url.clop.to_form
      self.submit(form)
    end

    # send arbitrary verb (only works with patch to taf2-curb)
    def verb(verb,url=nil)
      return false if !@curl_object.respond_to?(:http_verb)
      self.url = url if url
      self.clear_data
      self.headers["Referer"] = self.cur if self.use_referer
      self.http_verb(verb)
      self.set_data
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
      @header_data.add(myArr[0].to_s.strip,myArr[1].to_s.strip)
#      @header_data[myArr[0].to_s.strip] = myArr[1].to_s.strip
      return data.length.to_i
    end

    # send methods not defined here to <tt>@curl_object</tt>
    def method_missing(methodname, *args)
      @curl_object.send(methodname, *args)
    end

  end
end
