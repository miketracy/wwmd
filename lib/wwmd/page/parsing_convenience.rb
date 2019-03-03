module WWMD
  class Page

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
      return nil if forms.empty? || !forms[id]
      f = @forms[id]
      action   = f.action
      action ||= action
      action ||= cur
      action ||= "PARSE_ERROR"
      action = nil if cur.basename == action
      url_action = @urlparse.parse(self.cur,action).to_s
      type = f.type
      FormArray.new do |x|
        x.set_fields(f.fields)
        x.action = url_action
        x.type   = type
      end
    end

    # return the complete url to the form action on this page
    def action(id=nil)
      id = 0 if not id
      act = self.forms[id].action
      return self.last_effective_url if (act.nil? || act.empty?)
      return self.base_url + act
#      return @urlparse.parse(self.last_effective_url,act).to_s
    end

    # xpath search
    def search(xpath)
      self.scrape.hdoc.search(xpath)
    end

    # traverse
    def traverse(&block)
      self.scrape.hdoc.traverse(&block)
    end

    # return an array of inner_html for each <script> tag encountered
    def dump_scripts
      self.get_tags(".//script").map { |s| s.inner_html if s.inner_html.strip != '' }
    end

    alias_method :scripts, :dump_scripts

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

    def all_tags#:nodoc:
      return self.search("*").map { |x| x.name }
    end                                        

    def furl(url)
      self.url = @urlparse.parse(self.base_url,url).to_s
    end

    # set self.opts[:base_url]
    def setbase(url=nil)
      return nil if not url
      self.opts[:base_url] = url
      self.base_url = url
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

    # alias_method for body_data 
    def raw 
      self.body_data
    end
  end
end
