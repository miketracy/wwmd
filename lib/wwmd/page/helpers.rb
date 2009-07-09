module WWMD
  class Page
    # copy and paste from burp request windows
    # page object gets set with headers and url (not correct)
    # returns [headers,form]
    #   form = page.from_paste
    def from_paste
      self.enable_cookies = false
      req = %x[pbpaste]
      return false if not req
      h,b = req.chomp.split("\r\n\r\n",2)
      oh = h
      h = h.split("\r\n")
      m,u,p = h.shift.split(" ")
      return nil unless m =~ (/^(POST|GET)/)
      self.url = self.base_url + u
      self.headers_from_array(h)
      self.body_data = b
      self.set_data
      form = b.to_form
      form.action = @urlparse.parse(self.base_url, u).to_s
      [oh,form]
    end

    def resp_paste
      self.body_data = %x[pbpaste].split("\r\n\r\n",2)[1]
      self.set_data
    end
  end
end
