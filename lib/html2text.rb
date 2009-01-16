#!/usr/bin/env ruby
=begin rdoc
:include:../sig.do

html2text that works with Nokogiri
=end
module WWMD

  INLINETAGS =  ['a','abbr','acronym','address','b','bdo','big','cite',
                 'code','del','dfn','em','font','i','ins','kbd','label',
                 'noframes','noscript','q','s','samp','small','span',
                 'strike','strong','sub','sup','td','th','tt','u',
                 'html','body','table']
  BLOCKTAGS =   ['blockquote','center','dd','div','fieldset','form',
                 'h1','h2','h3','h4','h5','h6','p','pre','tr','var',]
  LISTTAGS =    ['dir','dl','menu','ol','ul']
  ITEMTAGS =    ['li','dt']
  SPECIALTAGS = ["br","hr"]

  class Page
    def html2text
      arr = []
      self.scrape.hdoc.traverse do |x|
        arr << [x.parent.name,x.text] if x.text?
        if x.elem?
          arr << [x.name,""] if SPECIALTAGS.include?(x.name)
        end
      end
      ret = ""
      arr.each do |name,str|
        (ret += "\n"; next ) if name == "br"
        (ret += "\n" + ("-" * 72) + "\n"; next) if name == "hr"
        s = str.strip
        if BLOCKTAGS.include?(name) or LISTTAGS.include?(name)
          s += "\n"
        elsif ITEMTAGS.include?(name)
          s = "* " + s + "\n"
        end
        ret += s
      end
      ret.gsub(/\n+/) { "\n" }
    end
  end
end
