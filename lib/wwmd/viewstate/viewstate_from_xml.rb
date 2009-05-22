module WWMD
  class ViewState
# directly serialize into stack from received xml (the easy way)
# this is pretty silly but it didn't take me very long so...

    attr_reader :xmlstack

    def get_sym(str)
      str.split(":").last.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1].gsub(/\Avs/,"").to_sym
    end

    def opcode(name,val)
      sym = get_sym(name)
      if sym == :value
        ret = VIEWSTATE_TYPES.index(val.to_sym)
      else
        ret = VIEWSTATE_TYPES.index(sym)
      end
      ret
    end

    def serialize_hashtable(node)
      tstack = ""
      tstack << self.write_7bit_encoded_int(node['size'].to_i)
      node.children.each do |c|
        next if c.text?
        raise "Invalid Hashtable: got #{c.name}" if not c.name == "Pair"
      end
      tstack
    end

    def decode_text(node)
      case node['encoding']
        when "urlencoded"
          node.inner_text.unescape
        when "quoted-printable"
          node.inner_text.from_qp
        when "base64"
          node.inner_text.b64d
        when "hexify"
          node.inner_text.dehexify
        else
          node.inner_text
      end
    end

    def write_node(node)
      return false if node.text?
      tstack = ""
      # this is a hack to get sparse_array to work
      return false if ["Pair","Key","Value"].include?(node.name) # skip and fall through
      if ["Index","Size","Elements"].include?(node.name)
        @xmlstack << self.write_7bit_encoded_int(node.inner_text.to_i)
        return false
      end
      if node.name == "Mac"
        @xmlstack << decode_text(node)
        return false
      end
      # end hack
      flag = true # begin; sillyness; rescue => me; end
      case get_sym(node.name)
        when :pair, :triplet, :value, :sparse_array, :type, :string_formatted
        when :int_enum, :known_color, :int32
          tstack << self.write_7bit_encoded_int(node.inner_text.to_i)
        when :int16
          tstack << self.write_short(node.inner_text.to_i)
        when :byte, :char, :indexed_string_ref
          tstack << self.write_byte(node.inner_text.to_i)
        when :color, :single
          tstack << self.write_int32(node.inner_text.to_i)
        when :double, :date_time
          tstack << self.write_double(node.inner_text.to_i)
        when :unit
          tstack << self.write_double(node['dword'].to_i)
          tstack << self.write_single(node['word'].to_i)
        when :list, :string_array, :array
          tstack << self.write_7bit_encoded_int(node['size'].to_i)
        when :string, :indexed_string, :binary_serialized
          flag = false if ([:string_array,:string_formatted].include?(get_sym(node.parent.name)))
          # get encoding
          str = decode_text(node)
          tstack << self.write_7bit_encoded_int(str.size)
          tstack << str
        when :hashtable, :hybrid_dict
          tstack << serialize_hashtable(node)
        else
          raise "Invalid Node:\n#{node.name}"
      end

      # [flag] is a hack to get around string_array and string_formatted emitting opcodes
      @xmlstack << self.write_byte(opcode(node.name,node.inner_text)) if flag
      if node.has_attribute?("typeref")
        if node['typeref'].to_i == 0x2b
          @xmlstack << self.serialize_type(node['typeref'].to_i,node['typeval'].to_i)
        else
          @xmlstack << self.serialize_type(node['typeref'].to_i,node['typeval'])
        end
      end
      @xmlstack << tstack
    end

    def serialize_xml(node)
      begin
        write_node(node)
      rescue => e
        STDERR.puts "ERROR parsing node:\n#{node.to_s}"
        raise e
      end
      node.children.each do |c|
        serialize_xml(c)
      end
    end

    def from_xml(xml)
      @xmlstack = ""
      doc = Nokogiri::XML.parse(xml)
      root = doc.root
      raise "Invalid ViewState Version" if not root.has_attribute?("version")
      @xmlstack << root['version'].b64d
      root.children.each do |c|
        serialize_xml(c)
      end
      self.deserialize(@xmlstack.b64e)
    end

  end
end
