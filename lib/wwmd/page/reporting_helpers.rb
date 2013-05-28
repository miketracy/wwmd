module WWMD
  class Page
    attr_accessor :status
#:section: Reporting helper methods
# These are methods that generate data for a parsed page

    # return text representation of page code
    #
    # override with specific statuses in helper depending on page text
    # etc to include statuses outside 200 = OK and other = ERR
    def page_status
      @status = "OK"
      @status = "ERR" if self.response_code > 399
    end

#    alias_method :status, :page_status#:nodoc:

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

    # return md5sum for self.body_data
    def md5
      return self.body_data.md5
    end

    # does this response have SET-COOKIE headers?
    def set_cookies?
      ret = FormArray.new()
      self.header_data.each do |x|
        if x[0].upcase == "SET-COOKIE"
          ret << x[1].split(";").first.split("=",2)
        end
      end
      ret
    end
    alias_method :set_cookies, :set_cookies?

    def time
      self.total_time
    end

    # return MD5 for DOM fingerprint
    # take all tag names in page.to_s.md5
    def fingerprint
      self.all_tags.to_s.md5
    end
    alias_method :fp, :fingerprint #:nodoc:

    # alias_method for last_effective_url
    def current_url
      self.last_effective_url
    end

    alias_method :current, :current_url
    alias_method :cur, :current_url
    alias_method :now, :current_url
#    alias_method :last, :current_url

    # the last http response code
    def code
      self.response_code # .to_s
    end

  end
end
