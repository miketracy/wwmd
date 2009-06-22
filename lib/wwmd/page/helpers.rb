module WWMD
  class Page
    # copy and paste from burp request windows
    # page object gets set with headers and url (not correct)
    # returns form
    #   form = page.from_paste
    def from_paste
      self.enable_cookies = false
      req = %x[pbpaste]
      return nil if not req
      h,b = req.chomp.split("\x0d\x0a\x0d\x0a")
      h = h.split("\r\n")
      m,u,p = h.shift.split(" ")
      return nil unless m =~ (/^(POST|GET)/)
      self.url = self.base_url + u
      self.headers_from_array(h)
      form = b.to_form
      form.action = @urlparse.parse(self.base_url, u).to_s
      form
    end
  end
end
