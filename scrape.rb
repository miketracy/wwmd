#!/usr/bin/env ruby
#:include:sig.do

module WWMD
  LINKS_REGEXP = [
    /window\.open\s*\(([^\)]+)/i,
    /open_window\s*\(([^\)]+)/i,
    /window\.location\s*=\s*(['"][^'"]+['"])/i,
    /.*location.href\s*=\s*(['"][^'"]+['"])/i,
    /document.forms.*action\s*=\s*(['"][^'"]+['"])/i,
    /Ajax\.Request\s*\((['"][^'"]+['"])/i,
  ]

  AJAX_REGEXP = [
    /Ajax\.Request\s*\((['"][^'"]+['"])/i,
  ]

  SRC_REGEXP = [
    /src=\s*(['"][^'"]+['"])/i
  ]

#  NOT_URL_CHAR = "[^0-9a-zA-Z\:\/\+\\-\%\#]"

  class Scrape

    attr_accessor :debug
    attr_accessor :warn
    attr_accessor :links  # links found on page
    attr_accessor :jlinks # links to javascript includes

    attr_reader :hdoc

    @debug    = false
    @warn     = true

    # create a new scrape object using passed HTML
    def initialize(page='')
      @page = page
      @hdoc = Hpricot(@page)
      @links = Array.new
      @debug = false
      @warn  = true
    end

    # reset this scrape object (called by WWMD::Page)
    def reset(page)
      @page = page
      @hdoc = Hpricot(@page)
      @links = Array.new
    end

    # scan the passed string for the configured regular expressions
    # and return them as an array
    def urls_from_regexp(content,re,split=0)
      ret = []
      scrape = content.scan(re)
      scrape.each do |url|
        # cheat and take split string(,)[split]
        add = url.to_s.split(',')[split].gsub(/['"]/, '')
        next if (add == '' || add.nil?)
        ret << add
      end
      return ret
    end

    # xpath search for tags and return the passed attribute
    #  urls_from_xpath("//a","href")
    def urls_from_xpath(xpath,attr)
      ret = []
      @hdoc.search(xpath).each do |elem|
        url = elem.get_attribute(attr)
        next if url.empty?
        ret << url.strip
      end
      return ret
    end

    # <b>NEED</b> to move this to external configuration
    #
    # list of urls we don't care to store in our links list
    def reject_links
      putw "WARN: override reject_links in helper script" if @warn
      default_reject_links
    end

    # default reject links (override using reject_links in helper script)
    def default_reject_links
      @links.reject! do |url|
        url.nil? ||
        url.extname == ".css" ||
        url.extname == ".pdf" ||
        url =~ /javascript:/i ||
        url =~ /mailto:/i ||
        url =~ /[\[\]]/ ||
        url =~ /^#/
      end
    end

    # define an urls_from_helper method in your task specific script
    def urls_from_helper
      putw "WARN: Please set an urls_from_helper override in your helper script" if @warn
      return nil
    end

    # use xpath searches to get
    # * //a href
    # * //area href
    # * //frame src
    # * //iframe src
    # * //form action
    # * //meta refresh content urls
    # then get //script tags and regexp out links in javascript function calls
    # from elem.inner_html
    def for_links(reject=true)
      self.urls_from_xpath("//a","href").each { |url| @links << url };      # get <a href=""> elements
      self.urls_from_xpath("//area","href").each { |url| @links << url };   # get <area href=""> elements
      self.urls_from_xpath("//frame","src").each { |url| @links << url };   # get <frame src=""> elements
      self.urls_from_xpath("//iframe","src").each { |url| @links << url };  # get <iframe src=""> elements
      self.urls_from_xpath("//form","action").each { |url| @links << url }; # get <form action=""> elements

      # <meta> refresh
      @hdoc.search("//meta").each do |meta|
        next if meta.get_attribute("http_equiv") != "refresh"
        @links << meta.get_attribute("content").split(/=/)[1].strip
      end

      # add urls from onclick handlers
      @hdoc.search("*[@onclick]").each do |onclick|
        LINKS_REGEXP.each do |re|
          self.urls_from_regexp(onclick.get_attribute("onclick"),re).each do |url|
            @links << url
          end
        end
      end

      # add urls_from_regexp (limit to <script> tags (elem.inner_html))
      @hdoc.search("//script").each do |scr|
        LINKS_REGEXP.each do |re|
          self.urls_from_regexp(scr.inner_html,re).each { |url| @links << url }
        end
      end

      # re-define urls_from_helper in what you mix in
      begin
        self.urls_from_helper
      end

      self.reject_links; # reject links we don't care about
      return @links
    end

    # scrape the page for <script src=""> tags
    def for_javascript_links
      urls = []
      @hdoc.search("//script[@src]").each { |tag| urls << tag.get_attribute("src") }
      urls.reject! { |url| File.extname(url).clip != ".js" }
      return urls
    end

    # scan page for comment fields
    def for_comments
      @page.scan(/\<!\s*--(.*?)--\s*\>/m).map { |x| x.to_s }
    end

    # scrape the page for a meta refresh tag and return the url from the contents attribute or nil
    def for_meta_refresh
      has_mr = @hdoc.search("//meta").map { |x| x.get_attribute('http-equiv') }.include?('Refresh')
      if has_mr
        urls = @hdoc.search("//meta[@content]").map { |x| x.get_attribute('content').split(";",2)[1] }
        if urls.size > 1
          STDERR.puts "PARSE ERROR: more than one meta refresh tag"
          return "ERR"
        end
        k,v = urls.first.split("=",2)
        if k.upcase.strip != "URL"
          STDERR.puts "PARSE ERROR: content attribute of meta refresh does not contain url"
          return "ERR"
        end
        return v.strip
      else
        return nil
      end
    end

    # scrape the page for a script tag that contains a bare location.href tag (to redirect the page)
    def for_javascript_redirect
      redirs = []
      @hdoc.search("//script").each do |scr|
        scr.inner_html.scan(/.*location.href\s*=\s*['"]([^'"]+)['"]/i).each { |x| redirs += x }
      end
      if redirs.size > 1
        STDERR.puts "PARSE ERROR: more than one javascript redirect"
        return "ERR"
      end
      return redirs.first if not redirs.empty?
      return nil
    end

    # renamed class variable (for backward compat)
    def warnings#:nodoc:
      return @warn
    end
  end
end
