#!/usr/bin/env ruby
#:include:sig.do

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
    attr_reader   :ignore

    DEFAULT_IGNORE = [
      /logoff/i,
      /logout/i,
    ]

    # pass me opts and an array of regexps to ignore
    # we have a set of sane(ish) defaults here
    def initialize(opts={},ignore=nil)
      @opts    = opts
      @visited = []
      @queued  = []
      @bypass  = []
      @local_only = true
      if !opts[:spider_local_only].nil?
        @local_only = opts[:spider_local_only]
      end
      @ignore = ignore || DEFAULT_IGNORE
    end

    # push an url onto the queue
    def push_url(url)
      return false if _check_ignore(url)
      if @local_only
        return false if not url =~ /#{@opts[:base_url]}/
      end
      @bypass.each { |b| return true if not (url =~ b).nil? }
      @queued.push(url) if (@visited.detect { |v| v == url }.nil? and @queued.detect { |q| q == url }.nil?)
      return true
    end

    # skip items in the queue
    def skip(tim=1)
      tim.times { |i| @queued.shift }
      return true
    end

    # get the next url in the queue
    def get_next
      return queued.shift
    end

    alias next get_next

    # more elements in the queue?
    def next?
      return !queued.empty?
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

    alias v show_visited

    # return the current queue (or the entry in the queue at [id]
    def show_queue(id=nil)
      if id.nil?
        @queued.each_index { |i| putx i.to_s + " :: " + @queued[i].to_s }
        return nil
      else
        return @queued[id]
      end
    end

    alias q show_queue

    # add url to queue
    def add(url='',links=[])
      @visited.push(url)
      links.each { |l| self.push_url l }
      return nil
    end

    # set up the ignore list
    # ignore list is an array of regexp objects
    # remember to set this up before calling any Page methods
    def set_ignore(arr)
      @ignore = arr
    end

    def _check_ignore(url)
      @ignore.each { |x| return true if !(url =~ x).nil? }
      return false
    end
  end
end
