module REXML
  class Element

    # pretty print (indent=0) to stdout or filename [fn]
    def pp(fn=nil)
      tmp = ""
      self.write(tmp,0)
      if fn
        tmp.write(fn)
        return fn
      else
        return tmp
      end
      nil
    end

  end
end
