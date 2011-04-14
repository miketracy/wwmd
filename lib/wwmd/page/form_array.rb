=begin rdoc
This is a weird kind of data structure for no other reason than
I wanted to keep the form inputs in order when they come in.

Accessing this either as a hash or an array (but => won't work)

Some of the methods in here are kept for backward compat before the refactor
and now everything in this array should be accessed with []= and []

Set :action and take a block.  Page#submit_form should take this and do the
right thing.
=end

module WWMD
  class FormArray < Array
    attr_accessor :action
    attr_accessor :type
    attr_accessor :delimiter
    attr_accessor :equals

    def initialize(fields=nil,action=nil,&block)
      set_fields(fields)
      @delimiter = "&"
      @equals = "="
      @action = action
      instance_eval(&block) if block_given?
    end

    def set_fields(fields=nil)
      return nil if fields.nil?
      # this first one is an array of field objects
      if fields.class == Array
        fields.each do |f|
          name = f['name']
          if self.name_exists(name)
            if f['type'] == "hidden"
              self.set name,f.get_value
            elsif f['type'] == "checkbox" and f.to_html.grep(/checked/) != ''
              self[name] = f.get_value
            end
          else
            self << [ f['name'],f.get_value ]
          end
        end
      elsif fields.class == Hash
        fields.each_pair { |k,v| self[k] = v }
      elsif fields.class == String
        fields.split(@delimiter).each do |f|
          k,v = f.split(@equals,2)
          self[k] = v
        end
      end
    end

    # "deep enough" copy of this object to make it a real copy
    # instead of references to the arrays that already exist
    def clone
      ret = self.class.new
      self.each { |r| ret << r.clone }
      ret.action = self.action
      return ret
    end

    def clear
      self.delete_if { |x| true }
    end

    # check if the passed name exists in the form
    def include?(key)
      self.map { |x| x.first }.flatten.include?(key)
    end

    alias_method :name_exists,  :include?#:nodoc:
    alias_method :name_exists?, :include?#:nodoc:
    alias_method :has_key?,     :include?#:nodoc:

    # add key/value pairs to form
    def add(key,value)
      self << [key,value]
    end

    # key = Fixnum set value at index key
    # key = String find key named string and set value
    def set_value!(key,value)
      if key.class == Fixnum
        self[key][1] = value
        return [self[key][0], value]
      end
      self.each_index do |i|
        if self[i][0] == key
          self[i] = [key,value]
        end
      end
      return [key,value]
    end

    # get a value using its index
    # override Array#[]
    alias_method :fa_get, :[]#:nodoc:
    def [](*args)
      if args.first.class == Fixnum
        self.fa_get(args.first)
      else
        self.get_value(args.first)
      end
    end

    alias_method :fa_set, :[]=#:nodoc:
    # set a key using its index, array key or add using a new key i.e.:
    # if setting:
    #  form = [['key','value'],['foo','bar']]
    #  form[0] = ["replacekey","newalue"]
    #  form["replacekey"] = "newervalue"
    # if adding:
    #  form["newkey"] = "value"
    #  
    def []=(*args)
      key,value = args
      if args.first.kind_of?(Fixnum)
        return self.fa_set(*args)
      elsif self.has_key?(key)
        return self.set_value(key,value)
      else
        return self.add(key,value)
      end
    end

    alias_method :set_value, :set_value!
    alias_method :set, :set_value!

    def get_value(key)
      if key.class == Fixnum
        return self[key][1]
      end
      self.each_index do |i|
        if self[i][0] == key
          return self[i][1]
        end
      end
      return nil
    end

    alias_method :get, :get_value

    def keys
      self.map { |k,v| k }
    end

    def setall!(value)
      self.each_index { |i| self.set_value!(i,value) }
    end

    alias_method :setall,   :setall!#:nodoc:
    alias_method :set_all!, :setall!#:nodoc:
    alias_method :set_all,  :setall!#:nodoc:

    # delete all key = value pairs from self where key = key
    def delete_key(key)
      self.reject! { |x,y| x == key }
    end

    alias_method :delete_keys!, :delete_key #:nodoc:
    alias_method :delete_key!,  :delete_key #:nodoc:

    # escape form keys in place
    def escape_keys!(reg=WWMD::ESCAPE[:url])
      return nil if reg == :none
      self.map! { |x,y| [x.escape(reg),y] }
    end

    # unescape form keys in place
    def unescape_keys!(reg=WWMD::ESCAPE[:url])
      return nil if reg == :none
      self.map! { |x,y| [x.unescape,y] }
    end

    # escape form values in place
    def escape_all!(reg=WWMD::ESCAPE[:url])
      return nil if reg == :none
      self.map! { |x,y| [x,y.escape(reg)] }
    end

    alias_method :escape_all, :escape_all!#:nodoc:

    # unescape all form values in place
    def unescape_all!
      self.map! { |x,y| [x,y.unescape] }
    end

    alias_method :unescape_all, :unescape_all!#:nodoc:

    # remove form elements with null values
    def remove_nulls!
      self.delete_if { |x| x[1].to_s.empty? || x[1].nil? }
    end

    alias_method :squeeze!, :remove_nulls!

    # remove form elements with null keys (for housekeeping returns)
    def remove_null_keys!
      self.delete_if { |x,y| x.to_s.empty? || x.nil? }
    end

    alias_method :squeeze_keys!, :remove_null_keys!

## viewstate

    # clear viewstate variables
    def clear_viewstate
      self.each { |k,v|
        self[k] = "" if k =~ /^__/
      }
    end

    # remove viewstate variables
    def rm_viewstate
      # my least favorite ruby idiom
      self.replace(self.map { |k,v| [k,v] if not k =~ /^__/ }.reject { |x| x.nil? })
    end

    alias_method :extend!, :add #:nodoc (this is here for backward compat)

    # add viewstate stuff
    def add_viewstate#:nodoc:
      self.insert(0,[ "__VIEWSTATE","" ])
      self.insert(0,[ "__EVENTARGUMENT","" ])
      self.insert(0,[ "__EVENTTARGET","" ])
      self.insert(0,[ "__EVENTVALIDATION","" ])
      return nil
    end

## conversions

    # convert form into a post parameters string
    def to_post
      ret = []
      self.each do |i|
        ret << i.join(@equals)
      end
      ret.join(@delimiter)
    end

    # convert form into a get parameters string
    #
    # pass me a base to get a full url to pass to Page.get
    def to_get(base="")
      return base if self.empty?
      ret = []
      self.each do |i|
        ret << i.join(@equals)
      end
      ret = ret.join(@delimiter)
      return base.to_s.clip + "?" + ret.to_s
    end

## parsing convenience

    # dump a web page containing a csrf example of the current FormArray
    def to_csrf(quot=nil,action=nil,unescval=false)
      quot = "'" unless quot
      action = self.action unless action
      ret = ""
      ret << "<html><body>\n"
      ret << "<form method=#{quot}post#{quot} id=#{quot}wwmdtest#{quot} name=#{quot}wwmdtest#{quot} action=#{quot}#{action}#{quot}>\n"
      self.each do |key,val|
        val.gsub!(/\+/," ")
        val = val.unescape.gsub(/'/) { %q[\'] } if unescval
        ret << "<input name=#{quot}#{key.to_s.unescape}#{quot} type=#{quot}hidden#{quot} value=#{quot}#{val.to_s.unescape}#{quot} />\n"
      end
      ret << "</form>\n"
      ret << "<script>document.wwmdtest.submit()</script>\n"
      ret << "</body></html>\n"
      return ret
    end

    # add markers for burp intruder to form
    def burpify(all=true) #:nodoc:
      ret = self.clone
      ret.each_index do |i|
        next if ret[i][0] =~ /^__/
#        ret.set_value!(i,"#{ret.get_value(i)}" + "\302\247" + "\302\247")
        if all
          ret.set_value!(i,"\244" + "#{ret.get_value(i)}" + "\244")
        else
          ret.set_value!(i,"#{ret.get_value(i)}" + "\244" + "\244")
        end          
      end
      ret.to_post.pbcopy
      return ret
    end

    # return md5 hash of sorted list of keys
    def fingerprint
      return (self.action.to_s + self.map { |k,v| k }.sort.to_s).md5
    end
    alias_method :fp, :fingerprint #:nodoc:

    def from_array(arr)
      self.clear
      arr.each { |k,v| self[k] = v }
    end

  end
end
