# Geoff Davis geoff at geoffdavis.net
# Wed May 2 20:08:44 EDT 2007
# http://rubyforge.org/pipermail/raleigh-rb-members/2007-May/000789.html

module HTML2Text
   InlineTags =  ['a','abbr','acronym','address','b','bdo','big','cite','code','del','dfn','em','font','i','ins','kbd','label','noframes','noscript','q','s','samp','small','span','strike','strong','sub','sup','td','th','tt','u','html','body','table']
   BlockTags =  ['blockquote','br','center','dd','div','fieldset','form','h1','h2','h3', 'h4','h5','h6','hr','p','pre','tr','var',]
   ListTags = ['dir','dl','menu','ol','ul']
   ListItemTags = ['li','dt']
   AsciiEquivalents =  {"amp"=>"&","bull"=>"*","copy"=>"(c)","laquo"=>"<<","raquo"=>">>","ge"=> ">=","le"=>"<=","mdash"=>"-","ndash"=>"-","plusmn"=>"+/-","times"=>"x"}

   NamedCharRegex = Regexp.new("(&("+Hpricot::NamedCharacters.keys.join("|")+");)")

   def self.element_to_text(n)
     tag = n.etag || n.stag
     name = tag.name.downcase
     s = ""
     is_block = BlockTags.include?(name)
     is_list = ListTags.include?(name)
     is_list_item = ListItemTags.include?(name)
     is_inline = InlineTags.include?(name)
     if is_block or is_list or is_list_item or is_inline
       n.each_child do |c|
         s += node_to_text(c)
       end
       if is_block or is_list
         s += "\n"
       elsif is_list_item
         s = "* " + s + "\n"
       end
     end
     s
   end

   def self.node_to_text(n)
     return "" if n.comment?
     return element_to_text(n) if n.elem?
     return n.inner_text if n.text?

     s = ""
     begin
       n.each_child do |c|
         s += node_to_text(c)
       end
     rescue => e
#       puts "WARNING: #{e.inspect}"
     end
     return s
   end

   def self.lookup_named_char(s)
     c = Hpricot::NamedCharacters[s[1...-1]]
     c.chr if c
   end

   def self.html2text(s)
     doc = Hpricot(s)
     text = node_to_text(doc)
     text.gsub!(NamedCharRegex){|s| "#{lookup_named_char(s)}"}
     # clean up white space
     text.gsub!("\r"," ")
     text.squeeze!(" ")
     text.strip!
     ret = ''
     text.split(/\n/).each do |l|
       l.strip!
       next if l == ''
       next if l =~ /^\?+$/
       ret += "#{l}\n"
     end
     return ret
   end
end
