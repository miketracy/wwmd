#!/usr/bin/env ruby
=begin rdoc
:include: ../sig.do
This is a weird kind of data structure for no other reason than
I wanted to keep the form inputs in order when they come in.

Accessing this either as a hash or an array (but => won't work)

Some of the methods in here are kept for backward compat before the refactor
and now everything in this array should be accessed with []= and []
=end

module WWMD
  class FormArray < Array

    def initialize(fields=nil)
      if not fields.nil?
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
          fields.split("&").each do |f|
            k,v = f.split("=",2)
            self[k] = v
          end
        end
      end
    end

    # "deep enough" copy of this object to make it a real copy
    # instead of references to the arrays that already exist
    def clone
      ret = self.class.new
      self.each { |r| ret << r.clone }
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

    alias_method :extend!, :add #:nodoc (this is here for backward compat)

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

    alias_method :old_get, :[]#:nodoc:
    def [](*args)
      if args.first.class == Fixnum
        self.old_get(args.first)
      else
        self.get_value(args.first)
      end
    end

    alias_method :old_set, :[]=#:nodoc:
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
        return self.old_set(*args)
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

    # convert form into a post parameters string
    def to_post
      ret = []
      self.each do |i|
        ret.push(i.join("="))
      end
      ret.join("&")
    end

    # convert form into a get parameters string
    #
    # pass me a base to get a full url to pass to Page.get
    def to_get(base="")
      ret = []
      self.each do |i|
        ret.push(i.join("="))
      end
      ret = ret.join("&")
      return base.clip + "?" + ret.to_s
    end

    # IRB: puts the form in human readable format
    # if you <tt>form.show(true)</tt> it will show unescaped values
    def show(unescape=false)
      if unescape
        self.each_index { |i| puts i.to_s + " :: " + self[i][0].to_s + " = " + self[i][1].to_s.unescape }
      else
        self.each_index { |i| puts i.to_s + " :: " + self[i][0].to_s + " = " + self[i][1].to_s }
      end
      return nil
    end

    # meh
    def add_viewstate#:nodoc:
      self.insert(0,[ "__VIEWSTATE","" ])
      self.insert(0,[ "__EVENTARGUMENT","" ])
      self.insert(0,[ "__EVENTTARGET","" ])
      return nil
    end

#    alias_method, :add_state, :add_viewstate#:nodoc:

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

    # dump a web page containing a csrf example of the current FormArray
    def to_csrf(action)
      ret = ""
      ret << "<html><body>\n"
      ret << "<form method='post' id='wwmdtest' name='wwmdtest' action='#{action}'>\n"
      self.each do |key,val|
        val = val.unescape.gsub(/'/) { %q[\'] }
            ret << "<input name='#{key.to_s.unescape}' type='hidden' value='#{val}' />\n"
#            ret << "<input name='#{key.to_s.unescape}' type='hidden' value='#{val.to_s.unescape.gsub(/'/,"\\'")}' />\n"
      end
      ret << "</form>\n"
      ret << "<script>document.wwmdtest.submit()</script>\n"
      ret << "</body></html>\n"
      return ret
    end

    def burpify #:nodoc:
      ret = self.clone
      ret.each_index do |i|
        next if ret[i][0] =~ /^__/
        ret.set_value!(i,"#{ret.get_value(i)}" + "\302\247" + "\302\247")
      end
      system("echo '#{ret.to_post}' | pbcopy")
      return ret
    end

    # return md5 hash of sorted list of keys
    def fingerprint
      return self.map { |k,v| k }.sort.to_s.md5
    end
    alias_method :fp, :fingerprint #:nodoc:

  end
end
