#!/usr/bin/env ruby
=begin rdoc
:include: sig.do
=end

module WWMD
  class Inputs
    attr_accessor :elems

    @cobj  = '' # wwmd object
    @elems = '' # array of Hpricot elems parse out by self.new()

    def initialize(*args)
      @cobj = args.shift
    end

    def show
      puts @elems
    end

    # call me from Page.set_data
    def set
      @elems = [@cobj.search("//input").map,@cobj.search("//select").map].flatten
    end

    def get(attr=nil)
      @elems.map { |x| x[attr] }.reject { |y| y.nil? }
    end

    #
    # return: FormArray containing all page inputs
    def form
      ret = {}
      @elems.map do |x|
        name  = x['name']
        id    = x['id']
        next if (name.nil? && id.nil?)
        value = x['value']
        type  = x['type']
        ret[name] = value
        ret[id] = value if ((id || name) != name)
      end
      return FormArray.new(ret)
    end

    #
    # return: FormArray containing get params
    def params
      return FormArray.new(@cobj.cur.clop.to_form)
    end
  end
end
