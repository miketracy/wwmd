module WWMD
  class Page

    # does this request have an authenticate header?
    def auth?
      return false if self.code != 401
      count = 0
      self.header_data.each do |i|
        if i[0] =~ /www-authenticate/i
          count += 1
        end
      end
      return (count > 0)
    end

  end
end
