module WWMD
  class ViewState
    attr_accessor :b64
    attr_accessor :obj_queue
    attr_accessor :mac
    attr_accessor :debug
    attr_reader   :raw
    attr_reader   :stack
    attr_reader   :bufarr
    attr_reader   :magic
    attr_reader   :size
    attr_reader   :indexed_strings
    attr_reader   :last_offset
    attr_reader   :xml
    attr_reader   :ndoc

    def initialize(b64=nil)
      @b64 = b64
      @raw = ""
      @stack = ""
      @obj_queue = []
      @bufarr = []
      @size = 0
      @indexed_strings = []
      @mac = nil
      @debug = false
      self.deserialize if b64
    end

    # mac_enabled?
    def mac_enabled?
      return !@mac.nil?
    end

    # deserialize
    def deserialize(b64=nil)
      @obj_queue = []
      @b64 = b64 if b64
      @raw = @b64.b64d
      @bufarr = @raw.scan(/./m)
      @size = @bufarr.size
      raise "Invalid ViewState" if not self.magic?
      @obj_queue << self.deserialize_value
      if @bufarr.size == 20 then
        @mac = bufarr.slice!(0..19).join("")
        dlog(0x00,"MAC = #{@mac.hexify}")
      end
      raise "Error Parsing Viewstate (left: #{@buffarr.size})" if not @bufarr.size == 0
      return !self.raw.nil?
    end

    def serialize(objs=nil,version=2)
      @obj_queue = objs if objs
      @stack << "\xFF\x01"
      @stack << @obj_queue.first.serialize
      @stack << @mac if @mac
      return !self.stack.nil?
    end

    def to_xml
      @xml = REXML::Document.new()
      header = REXML::Element.new("ViewState")
      header.add_attribute("version", @magic.b64e)
      header.add_attribute("version_string", @magic.hexify)
      header.add_element(@obj_queue.first.to_xml)
      if self.mac_enabled?
        max = REXML::Element.new("Mac")
        max.add_attribute("encoding","hexify")
        max.add_text(@mac.hexify)
        header.add_element(max)
      end
      @xml.add_element(header)
      @xpa = Nokogiri::XML.parse(@xml.to_s)
      self
    end

    # xpath search the nokogiri doc if we have one
    def search(*args)
      return "No XML" if !@ndoc
      @ndoc.search(*args)
    end

    # move pp due to to_xml returning self
    # this is all for the sake of getting #search to work
    def pp(*args)
      return "Undefined" if !@xml
      @xml.pp(*args)
    end

    def from_yaml(yaml)
      @obj_queue = YAML.load(yaml)
    end

    def to_yaml
      @obj_queue.to_yaml
    end

 end
end
