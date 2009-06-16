module WWMD
  class Page
    # copy and paste from burp request windows
    def from_paste
      req = %x[pbpaste]
      return nil if not req
      h,b = req.chomp.split("\x0d\x0a\x0d\x0a")
      h = h.split("\r\n")
      m,u,p = h.shift.split(" ")
      return nil unless m =~ (/^(POST|GET)/)
      self.url = self.opts[:base_url] + u
      self.headers_from_array(h)
      return b.to_form
    end
  end
end
