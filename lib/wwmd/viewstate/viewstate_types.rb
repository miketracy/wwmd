module WWMD
#    private const byte Marker_Format = 0xff;
#    private const byte Marker_Version_1 = 1;
#    private const int StringTableSize = 0xff;

  VIEWSTATE_MAGIC = ["\xff\x01"] unless defined?(VIEWSTATE_MAGIC)

  VIEWSTATE_TYPES = {
# System.Web.UI.LosFormatter
# System.Web.UI.ObjectStateFormatter
#   .DeserializeValue

    0x00 => :debug,               ##X  debugging
    0x01 => :int16,               #RX  private const byte Token_Int16 = 1;
    0x02 => :int32,               #RX  private const byte Token_Int32 = 2;
    0x03 => :byte,                #RX  private const byte Token_Byte = 3;
    0x04 => :char,                #RX  private const byte Token_Char = 4;
    0x05 => :string,              ##X  private const byte Token_String = 5;
    0x06 => :date_time,           #RX  private const byte Token_DateTime = 6;
    0x07 => :double,              #RX  private const byte Token_Double = 7;
    0x08 => :single,              #RX  private const byte Token_Single = 8;
    0x09 => :color,               ##X  private const byte Token_Color = 9;
    0x0a => :known_color,         ##X  private const byte Token_KnownColor = 10;
    0x0b => :int_enum,            ##X  private const byte Token_IntEnum = 11;
    0x0c => :empty_color,         #VX  private const byte Token_EmptyColor = 12;
    0x0f => :pair,                ##X  private const byte Token_Pair = 15;
    0x10 => :triplet,             ##X  private const byte Token_Triplet = 0x10;
    0x14 => :array,               ##X  private const byte Token_Array = 20;
    0x15 => :string_array,        ##X  private const byte Token_StringArray = 0x15;
    0x16 => :list,                ##X  private const byte Token_ArrayList = 0x16;
    0x17 => :hashtable,           ##X  private const byte Token_Hashtable = 0x17
    0x18 => :hybrid_dict,         ##X  private const byte Token_HybridDictionary = 0x18;
    0x19 => :type,                ##X  private const byte Token_Type = 0x19;
    0x1b => :unit,                ##X  private const byte Token_Unit = 0x1b;
    0x1c => :empty_unit,          #VX  private const byte Token_EmptyUnit = 0x1c;
    0x1e => :indexed_string,      ##X  private const byte Token_IndexedStringAdd = 30;
    0x1f => :indexed_string_ref,  ##X  private const byte Token_IndexedString = 0x1f;
    0x28 => :string_formatted,    ##X  private const byte Token_StringFormatted = 40;
    0x29 => :typeref_add,         ##X  private const byte Token_TypeRefAdd = 0x29;
    0x2a => :typeref_add_local,   ##X  private const byte Token_TypeRefAddLocal = 0x2a;
    0x2b => :typeref,             ##X  private const byte Token_TypeRef = 0x2b;
    0x32 => :binary_serialized,   ##X  private const byte Token_BinarySerialized = 50;
    0x3c => :sparse_array,        ##X  private const byte Token_SparseArray = 60;
    0x64 => :null,                #VX  private const byte Token_Null = 100;
    0x65 => :empty_byte,          #VX  private const byte Token_EmptyString = 0x65;
    0x66 => :zeroint32,           #VX  private const byte Token_ZeroInt32 = 0x66;
    0x67 => :bool_true,           #VX  private const byte Token_True = 0x67;
    0x68 => :bool_false,          #VX  private const byte Token_False = 0x68;
  } unless defined?(VIEWSTATE_TYPES)

end

if __FILE__ == $0
  puts "size: #{WWMD::VIEWSTATE_TYPES.size}"
end
