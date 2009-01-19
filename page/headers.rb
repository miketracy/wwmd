#!/usr/bin/env ruby
#:include:sig.do

module WWMD
  class Page

#:section: Header helper methods

    # clear header at <key>
    def clear_header(key)
      self.headers.delete_if { |k,v| k.upcase == key.upcase }
      return nil
    end

    alias_method :delete_header, :clear_header#:nodoc:

    # clear all headers
    def clear_headers
      self.headers.delete_if { |k,v| true }
      "headers cleared"
    end

    # set headers from passed argument
    #  Nil:    set headers from WWMD::DEFAULT_HEADERS
    #  Symbol: entry in WWMD::HEADERS to set from
    #  Hash:   hash to set headers from
    #  String: filename (NOT IMPLEMENTED)
    #
    #  if clear == true then headers will be cleared before setting
    def set_headers(arg=nil,clear=false)
      self.clear_headers if clear
      if arg.nil?
        begin
          self.clear_headers
          WWMD::DEFAULT_HEADERS.each { |k,v| self.headers[k] = v }
          return "headers set from default"
        rescue => e
          puts e
          return "error setting headers"
        end
      elsif arg.class == Symbol
        self.set_headers(WWMD::HEADERS[arg])
        return "headers set from #{arg}"
      elsif arg.class == Hash
        arg.each { |k,v| self.headers[k] = v }
        return "headers set from hash"
      end
      "error setting headers"
    end

    # set headers back to default headers
    def default_headers(arg=nil)
      self.set_headers
    end

    alias_method :set_default, :default_headers

    # set headers from text
    def headers_from_array(arr)
      self.clear_headers
      arr.each do |line|
        h = line.split(":",2)
        next if h[1].class != String
        self.headers[h[0]] = h[1].strip
      end
    end

    # set headers from file
    def headers_from_file(fn)
      self.clear_headers
      File.read(fn).each do |line|
        h = line.split(":",2)
        next if h[1].class != String
        self.headers[h[0]] = h[1].strip
      end
      return nil
    end

    # set headers to utf7 encoding post
    def set_utf7_headers
      self.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-7"
      "headers set to utf7"
    end

    # set headers to ajax
    def set_ajax_headers
      self.headers["X-Requested-With"] = "XMLHttpRequest"
      self.headers["X-Prototype-Version"] = "1.5.0"
      return "headers set to ajax"
    end

    # set headers to SOAP request headers
    def set_soap_headers
      self.headers['Content-Type'] = "text/xml;charset=utf-8"
      self.headers['SOAPAction'] = "\"\""
      return "headers set to soap"
    end

    # get the current Cookie header
    def get_cookie
      self.headers["Cookie"]
    end

    # set the Cookie header
    def set_cookie(cookie=nil)
      self.headers["Cookie"] = cookie
    end

  end
end
