=begin rdoc
this file contains methods to help operations in irb (display methods etc.).
=end
module WWMD
  class Page

#:section: IRB helper methods

    def head(i=1)
      if i.kind_of?(Range)
        puts self.body_data.split("\n")[i].join("\n")
        return nil
      end
      puts self.body_data.head(i)
    end

    # IRB: text report what has been parsed from this page
    def report(short=nil)
      putx "-------------------------------------------------"
      self.summary
      putx "---- links found [#{self.has_links?.to_s} | #{self.links.size}]"
      self.links.each_index { |i| putx "#{i.to_s} :: #{@links[i]}" } if short.nil?
      putx "---- javascript found [#{self.has_jlinks?.to_s} | #{self.jlinks.size}]"
      self.jlinks.each { |url| putx url } if short.nil?
      putx "---- forms found [#{self.has_form?.to_s} | #{self.forms.size}]"
      putx "---- comments found [#{self.has_comments?.to_s}]"
      return nil
    end

    alias_method :show, :report#:nodoc:

    # IRB: display summary of what has been parsed from this page
    def summary
      status = self.page_status
      putx "XXXX[#{self.report_flags}] | #{self.response_code.to_s} | #{status} | #{self.url} | #{self.size}"
      return nil
    end

    # IRB: display current headers
    def request_headers
      self.headers.each_pair { |k,v| putx "#{k}: #{v}" }
      return nil
    end

    alias_method :show_headers, :request_headers#:nodoc:
    alias_method :req_headers, :request_headers#:nodoc:

    # IRB: display response headers
    def response_headers
      self.header_data.each { |x| putx "#{x[0]} :: #{x[1]}" }
      return nil
    end

    alias_method :resp_headers, :response_headers#:nodoc:

    # display self.body_data
    def dump_body
      putx self.body_data
    end

    alias_method :dump, :dump_body#:nodoc:

    # IRB: puts the page filtered through html2text
    def to_text; putx self.html2text; end
    def text; self.html2text; end

    # IRB: display a human readable report of all forms contained in page.body_data
    def all_forms
      self.forms.each_index { |x| putx "[#{x.to_s}]-------"; self.forms[x].report }
      nil
    end

    def onclicks
      self.search("//*[@onclick]").each { |x| puts x[:onclick] }
      nil
    end

    # hexdump self.body_data
    def hexdump
      puts self.body_data.hexdump
    end

    # this only works on a mac so get a mac
    def open #:nodoc:
      fn = "wwmdtmp_#{Guid.new}.html"
      self.write(fn)
      %x[open #{fn}]
    end
  end

  class Form
    def report
      return nil if not WWMD::console
      putx "action = #{self.action}"
      self.fields.each { |field| putx field.to_text }
      return nil
    end
    alias_method :show, :report
  end

  class FormArray
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

  end
end
