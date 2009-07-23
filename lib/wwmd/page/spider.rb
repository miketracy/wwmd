module WWMD
  # when a WWMD::Page object is created, it created its own WWMD::Spider object
  # which can be accessed using <tt>page.spider.method</tt>.  The <tt>page.set_data</tt>
  # method calls <tt>page.spider.add</tt> with the current url and a list of scraped
  # links from the page.  This class doesn't do any real heavy lifting.
  #
  # a simple spider can be written just by recursing through page.spider.next until
  # it's empty.  
  class Spider

    attr_accessor :queued
    attr_accessor :visited
    attr_accessor :bypass
    attr_accessor :local_only
    attr_reader   :opts
    attr_accessor :ignore
    attr_accessor :csrf_token

    DEFAULT_IGNORE = [
      /logoff/i,
      /logout/i,
    ]

    # pass me opts and an array of regexps to ignore
    # we have a set of sane(ish) defaults here
    def initialize(opts={},ignore=nil,&block)
      @block ||= block
      @opts    = opts
      @visited = []
      @queued  = []
      @local_only = true
      @csrf_token = nil
      if !opts[:spider_local_only].nil?
        @local_only = opts[:spider_local_only]
      end
      @ignore = ignore || DEFAULT_IGNORE
    end

    # push an url onto the queue
    def push_url(url)
      return false if _check_ignore(url)
      if @local_only
        return false if !(url =~ /#{@opts[:base_url]}/)
      end
      return false if (@visited.include?(url) or @queued.include?(url))
      @queued.push(url)
      true
    end

    # skip items in the queue
    def skip(tim=1)
      tim.times { |i| @queued.shift }
      true
    end

    # get the next url in the queue
    def get_next
      queued.shift
    end

    alias_method :next, :get_next

    # more elements in the queue?
    def next?
      !queued.empty?
    end

    # get the last ul we visited?  this doesn't look right
    def get_last(url)
      tmp =  @visited.reject { |v| v =~ /#{url}/ }
      return tmp[-1]
    end

    # show the visited list (or the entry in the list at [id])
    def show_visited(id=nil)
      if id.nil?
        @visited.each_index { |i| putx i.to_s + " :: " + @visited[i].to_s }
        return nil
      else
        return @visited[id]
      end
    end

    alias_method :v, :show_visited

    # return the current queue (or the entry in the queue at [id]
    def show_queue(id=nil)
      if id.nil?
        @queued.each_index { |i| putx i.to_s + " :: " + @queued[i].to_s }
        return nil
      else
        return @queued[id]
      end
    end

    alias_method :q, :show_queue

    # add url to queue
    def add(url='',links=[])
      return nil if @visited.include?(url)
      @visited.push(url)
      links.each { |l| self.push_url l }
      nil
    end

    # set up the ignore list
    # ignore list is an array of regexp objects
    # remember to set this up before calling any Page methods
    def set_ignore(arr)
      @ignore = arr
    end

    def _de_csrf(url)
      return url if @csrf_token.nil?
      act,params = url.clopa
      form = params.to_form
      return url if !form.has_key?(@csrf_token)
      form[@csrf_token] = ''
      url = act + form.to_get
    end

    def _check_ignore(url)
      @ignore.each { |x| return true if (url =~ x) }
      return false
    end
  end
end
