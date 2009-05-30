#
# CFPropertyList implementation
# class to read, manipulate and write both XML and binary property list
# files (plist(5)) as defined by Apple
#
# == Example
#
#   # create a arbitrary data structure of basic data types
#   data = {
#     'name' => 'John Doe',
#     'missing' => true,
#     'last_seen' => Time.now,
#     'friends' => ['Jane Doe','Julian Doe']
#     'likes' => {
#       'me' => false
#     }
#   }
#
#   # create CFPropertyList object
#   plist = CFPropertyList.new
#
#   # call CFPropertyList.guess() to create corresponding CFType values
#   plist.value = CFPropertyList.guess(data)
#
#   # write plist to file
#   plist.save("example.plist",CFPropertyList::FORMAT_BINARY)
#
#   # … later, read it again
#   plist = CFPropertyList.new("example.plist")
#   data = CFPropertyList.native_types(plist.value)
# 
# Author::    Christian Kruse (mailto:cjk@wwwtech.de)
# Copyright:: Copyright (c) 2009
# License::   Distributes under the same terms as Ruby

require 'libxml'
require 'kconv'

require 'rbCFFormatError.rb'
require 'rbCFTypes.rb'

# Implements the property list parser for both, XML and binary
class CFPropertyList
  # detect plist file format automatically
  FORMAT_AUTO   = -1
  # binary format plist file
  FORMAT_BINARY = 0
  # XML format plist file
  FORMAT_XML    = 1

  # the filename of the file we are reading/writing; may be nil
  attr_accessor :filename
  # the format of the file we are reading/writing; may be FORMAT_AUTO, FORMAT_BINARY or FORMAT_XML
  attr_accessor :format
  # the root value in the plist file
  attr_accessor :value

  # Constructor to initialize the parser
  # fname = nil:: The filename to read from
  # format = CFPropertyList::FORMAT_AUTO:: The format of the property list, may be FORMAT_AUTO
  def initialize(fname=nil,format=CFPropertyList::FORMAT_AUTO)
    @filename = fname
    @format = format
    load @filename unless @filename.nil?
  end

  # read a XML plist file
  # filename = nil:: The filename to read from; if nil, read from the file defined by instance variable +filename+
  def load_xml(filename=nil)
    load(filename,CFPropertyList::FORMAT_XML)
  end

  # read a binary plist file
  # filename = nil:: The filename to read from; if nil, read from the file defined by instance variable +filename+
  def load_binary(filename=nil)
    load(filename,CFPropertyList::FORMAT_BINARY)
  end

  # Read a plist file
  # file = nil:: The filename of the file to read. If nil, use +filename+ instance variable
  # format = nil:: The format of the plist file. Auto-detect if nil
  def load(file=nil,format=nil)
    file = @filename if file.nil?
    format = @format if format.nil?
    @value = Array.new

    raise IOError.new("File #{file} not readable!") unless File.readable? file

    case format
    when FORMAT_BINARY then
      read_binary(file)
    when FORMAT_XML then
      read_xml(file)
    else
      magic_number = IO.read(file,8)
      filetype = magic_number[0..5]
      version = magic_number[6..7]

      if filetype == "bplist" then
        raise CFFormatError.new("Wong file version #{version}") unless version == "00"
        read_binary(file)
      else
        read_xml(file)
      end
    end
  end

  # Serialize CFPropertyList object to XML format and write it to file
  # file = nil:: The filename of the file to write to. Uses +filename+ instance variable if nil
  def save_xml(file=nil)
    save(file,FORMAT_XML)
  end

  # Serialize CFPropertyList object to binary format and write it to file
  # file = nil:: The filename of the file to write to. Uses +filename+ instance variable if nil
  def save_binary(file=nil)
    save(file,FORMAT_BINARY)
  end

  # Serialize CFPropertyList object to specified format and write it to file
  # file = nil:: The filename of the file to write to. Uses +filename+ instance variable if nil
  # format = nil:: The format to save in. Uses +format+ instance variable if nil
  def save(file=nil,format=nil)
    format = @format if format.nil?
    file = @filename if file.nil?

    raise CFFormatError.new("Format #{format} not supported, use CFPropertyList::FORMAT_BINARY or CFPropertyList::FORMAT_XML") if format != FORMAT_BINARY && format != FORMAT_XML

    if(!File.exists?(file)) then
      raise IOError.new("File #{file} not writable!") unless File.writable?(File.dirname(file))
    elsif(!File.writable?(file)) then
      raise IOError.new("File #{file} not writable!")
    end

    content = format == FORMAT_BINARY ? to_binary() : to_xml()

    File.open(file, 'wb') {
      |fd|
      fd.write content
    }
  end

  # serialize CFPropertyList object to XML
  # formatted = false:: Use indention and line breaks
  def to_xml(formatted=false)
    doc = LibXML::XML::Document.new

    doc.root = LibXML::XML::Node.new('plist')
    doc.encoding = LibXML::XML::Encoding::UTF_8

    doc.root['version'] = '1.0'
    doc.root << @value.to_xml

    # ugly hack, but there's no other possibility I know
    str = doc.to_s(:indent => formatted)
    str1 = String.new
    str.each_line do
      |line|
      str1 << line
      str1 << "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" if line =~ /<\?xml/
    end

    return str1
  end

  # serialize CFPropertyList object to binary format
  def to_binary
    @unique_table = Hash.new
    @count_objects = 0
    @string_size = 0
    @int_size = 0
    @misc_size = 0
    @object_refs = 0

    @written_object_count = 0
    @object_table = Array.new
    @object_ref_size = 0

    @offsets = Array.new()

    binary_str = "bplist00"
    unique_and_count_values(@value)

    @count_objects += @unique_table.count
    @object_ref_size = CFPropertyList.bytes_needed(@count_objects)
    file_size = @string_size + @int_size + @misc_size + @object_refs * @object_ref_size + 40
    offset_size = CFPropertyList.bytes_needed(file_size)
    table_offset = file_size - 32

    @object_table = Array.new
    @written_object_count = 0
    @unique_table = Hash.new # we needed it to calculate several values, but now we need an empty table
    @value.to_binary(self)

    object_offset = 8
    offsets = Array.new

    0.upto(@object_table.count-1) do
      |i|
      binary_str += @object_table[i]
      offsets[i] = object_offset
      object_offset += @object_table[i].bytes.count
    end

    offsets.each do
      |offset|
      binary_str += CFPropertyList.pack_it_with_size(offset_size, offset)
    end


    binary_str += [offset_size, @object_ref_size].pack("x6CC")
    binary_str += [@count_objects].pack("x4N")
    binary_str += [0].pack("x4N")
    binary_str += [table_offset].pack("x4N")

    return binary_str
  end

  # Create CFType hierarchy by guessing the correct CFType, e.g.
  #
  #  x = {
  #    'a' => ['b','c','d']
  #  }
  #  cftypes = CFPropertyList.guess(x)
  def CFPropertyList.guess(object)
    return if object.nil?

    case object.class.to_s
    when 'Fixnum', 'Integer'
      return CFInteger.new(object)
    when 'Float'
      return CFReal.new(object)
    when 'String'
      return CFString.new(object)
    when 'Time'
      return CFDate.new(object)
    when 'Array'
      ary = Array.new
      object.each do
        |o|
        ary.push CFPropertyList.guess(o)
      end

      return CFArray.new(ary)
    when 'Hash'
      hsh = Hash.new
      object.each_pair do
        |k,v|
        hsh[k] = CFPropertyList.guess(v)
      end

      return CFDictionary.new(hsh)
    end
  end

  # Converts a CFType hiercharchy to native Ruby types
  def CFPropertyList.native_types(object)
    return if object.nil?

    case object.class.to_s
    when 'CFDate', 'CFString', 'CFInteger', 'CFReal', 'CFBoolean'
      return object.value
    when 'CFData'
      return object.decoded_value
    when 'CFArray'
      ary = Array.new
      object.value.each do
        |v|
        ary.push CFPropertyList.native_types(v)
      end

      return ary
    when 'CFDictionary'
      hsh = Hash.new
      object.value.each_pair do
        |k,v|
        hsh[k] = CFPropertyList.native_types(v)
      end

      return hsh
    end
  end

  # Create a type byte for binary format as defined by apple
  def CFPropertyList.type_bytes(type,type_len)
    optional_int = ""

    if(type_len < 15) then
      type += sprintf("%x",type_len)
    else 
      type += "f"
      optional_int = CFPropertyList.int_bytes(type_len)
    end

    return [type].pack("H*") + optional_int
  end

  # calculate how many bytes are needed to save +count+
  def CFPropertyList.bytes_needed(count)
    nbytes = 0

    while count >= 1 do
      nbytes += 1
      count /= 256
    end

    return nbytes
  end

  # create integer bytes of +int+
  def CFPropertyList.int_bytes(int)
    intbytes = ""

    if(int > 0xFFFF) then
      intbytes = "\x12" + [int].pack("N") # 4 byte integer
    elsif(int > 0xFF) then
      intbytes = "\x11" + [int].pack("n") # 2 byte integer
    else
      intbytes = "\x10" + [int].pack("C") # 8 byte integer
    end

    return intbytes
  end

  # pack an +int+ of +nbytes+ with size
  def CFPropertyList.pack_it_with_size(nbytes,int)
    format = ["C", "n", "N", "N"][nbytes-1]

    if(nbytes == 3) then
      val = [int].pack(format)
      return val.slice(-3)
    end

    return [int].pack(format)
  end

  # calculate how many bytes are needed to save +int+
  def CFPropertyList.bytes_int(int)
    nbytes = 1

    nbytes += 1 if int > 0xFF # 2 byte integer
    nbytes += 2 if int > 0xFFFF # 4 byte integer
    nbytes += 4 if int > 0xFFFFFFFF # 8 byte integer
    nbytes += 7 if int < 0 # 8 byte integer (since it is signed)

    return nbytes + 1 # one „marker” byte
  end

  # calculate how many bytes are needed to save the size +int+
  def CFPropertyList.bytes_size_int(int)
    int = int.to_i
    nbytes = 0

    nbytes += 2 if int > 0xE # 2 size-bytes
    nbytes += 1 if int > 0xFF # 3 size-bytes
    nbytes += 2 if int > 0xFFFF # 5 size-bytes

    return nbytes
  end

  # convert string to binary format. If string contains non-ascii characters,
  # it will create a „unicode string” (i.e. a utf16be string)
  def string_to_binary(val)
    saved_object_count = -1

    unless(@unique_table.has_key?(val)) then
      saved_object_count = @written_object_count
      @written_object_count += 1
      @unique_table[val] = saved_object_count

      if(!val.ascii_only?) then
        bdata = CFPropertyList.type_bytes("6", val.length) # 6 is 0110, unicode string (utf16be)
        val = val.encode("UTF-16BE")
        @object_table[saved_object_count] = bdata + val.bytes.join("")
      else
        bdata = CFPropertyList.type_bytes("5", val.length) # 5 is 0101 which is an ASCII string (seems to be ASCII encoded)
        @object_table[saved_object_count] = bdata + val
      end
    else
      saved_object_count = @unique_table[val]
    end

    return saved_object_count
  end

  # convert a nummeric value to binary
  def num_to_binary(value)
    saved_object_count = @written_object_count
    @written_object_count += 1

    val = ""
    if(value.class == CFInteger) then
      val = int_to_binary(value.value)
    else
      val = real_to_binary(value.value)
    end

    @object_table[saved_object_count] = val
    return saved_object_count
  end

  # convert an boolean to binary
  def bool_to_binary(val)
    saved_object_count = @written_object_count
    @written_object_count += 1

    @object_table[saved_object_count] = val ? "\x9" : "\x8" # 0x9 is 1001, type indicator for true; 0x8 is 1000, type indicator for false
    return saved_object_count
  end

  # convert a date value to binary
  def date_to_binary(val)
    saved_object_count = @written_object_count
    @written_object_count += 1

    val = val.getutc.to_f - CFDate::DATE_DIFF_APPLE_UNIX # CFDate is a real, number of seconds since 01/01/2001 00:00:00 GMT

    bdata = CFPropertyList.type_bytes("3", 3) # 3 is 0011, type indicator for date
    @object_table[saved_object_count] = bdata + [val].pack("d").reverse

    return saved_object_count
  end

  # convert binary data value to binary plist format
  def data_to_binary(val)
    saved_object_count = @written_object_count
    @written_object_count += 1

    bdata = CFPropertyList.type_bytes("4", val.length) # a is 1000, type indicator for data
    @object_table[saved_object_count] = bdata + val

    return saved_object_count
  end

  # convert an array to binary format, including all children
  def array_to_binary(val)
    saved_object_count = @written_object_count
    @written_object_count += 1

    bdata = CFPropertyList.type_bytes("a", val.value.count) # a is 1010, type indicator for arrays

    val.value.each do
      |v|
      bval = v.to_binary(self)
      bdata += CFPropertyList.pack_it_with_size(@object_ref_size, bval)
    end

    @object_table[saved_object_count] = bdata
    return saved_object_count
  end

  # convert a dict value to binary format, including all children
  def dict_to_binary(val)
    saved_object_count = @written_object_count
    @written_object_count += 1
    bdata = CFPropertyList.type_bytes("d", val.value.length) # d=1101, type indicator for dictionary

    val.value.each_key do
      |k|
      str = CFString.new(k)
      key = str.to_binary(self)
      bdata += CFPropertyList.pack_it_with_size(@object_ref_size, key)
    end

    val.value.each_value do
      |v|
      bval = v.to_binary(self)
      bdata += CFPropertyList.pack_it_with_size(@object_ref_size, bval)
    end

    @object_table[saved_object_count] = bdata
    return saved_object_count
  end

  protected
    # convert an integer value to binary format
    def int_to_binary(value)
      nbytes = 0
      nbytes = 1 if value > 0xFF # 1 byte integer
      nbytes += 1 if value > 0xFFFF # 4 byte integer
      nbytes += 1 if value > 0xFFFFFFFF # 8 byte integer
      nbytes = 3 if value < 0 # 8 byte integer, since signed

      bdata = CFPropertyList.type_bytes("1", nbytes) # 1 is 0001, type indicator for integer
      buff = ""

      if(nbytes < 3) then
        fmt = "N"

        if(nbytes == 0) then
          fmt = "C"
        elsif(nbytes == 1)
          fmt = "n"
        end

        buff = [value].pack(fmt)
      else
        high_word = value >> 32
        low_word = value & 0xFFFFFFFF
        buff = [high_word,low_word].pack("NN")
      end

      return bdata+buff
    end

    # convert a real value to binary format
    def real_to_binary(val)
      bdata = CFPropertyList.type_bytes("2", 3) # 2 is 0010, type indicator for reals
      buff = [val].pack("d")
      return bdata + buff.reverse
    end

    # „unique” and count values. „Unique” means, several objects (e.g. strings)
    # will only be saved once and referenced later
    def unique_and_count_values(value)
      # no uniquing for other types than CFString and CFData
      if(value.class == CFInteger || value.class == CFReal) then
        val = value.value
        if(value.class == CFInteger) then
          @int_size += CFPropertyList.bytes_int(val)
        else
          @misc_size += 9 # 9 bytes (8 + marker byte) for real
        end

        @count_objects += 1
        return
      elsif(value.class == CFDate) then
        @misc_size += 9 # since date in plist is real, we need 9 byte (8 + marker byte)
        @count_objects += 1
        return
      elsif(value.class == CFBoolean) then
        @count_objects += 1
        @misc_size += 1
        return
      elsif(value.class == CFArray) then
        cnt = 0
        value.value.each do
          |v|
          cnt += 1
          unique_and_count_values(v)
          @object_refs += 1 # each array member is a ref
        end

        @count_objects += 1
        @int_size += CFPropertyList.bytes_size_int(cnt)
        @misc_size += 1 # marker byte for array
        return
      elsif(value.class == CFDictionary) then
        cnt = 0
        value.value.each_pair do
          |k,v|
          cnt += 1
          if(!@unique_table.has_key?(k)) then
            @unique_table[k] = 0
            @string_size += k.length + 1
            @int_size += CFPropertyList.bytes_size_int(k.length)
          end

          @object_refs += 2 # both, key and value, are refs
          @unique_table[k] += 1
          unique_and_count_values(v)
        end

        @count_objects += 1
        @misc_size += 1 # marker byte for dict
        @int_size += CFPropertyList.bytes_size_int(cnt)
        return
      elsif(value.class == CFData) then
        val = value.decoded_value
        @int_size += CFPropertyList.bytes_size_int(val.length)
        @misc_size += val.length + 1
        @count_objects += 1
        return
      end

      val = value.value

      if(!@unique_table.has_key?(val)) then
        @unique_table[val] = 0
        @string_size += val.length + 1
        @int_size += CFPropertyList.bytes_size_int(val)
      end

      @unique_table[val] += 1
    end

    # read a „null” type (i.e. null byte, marker byte, bool value)
    def read_binary_null_type(length)
      case length
      when 0 then return 0 # null byte
      when 8 then return CFBoolean.new(false)
      when 9 then return CFBoolean.new(true)
      when 15 then return 15 # fill type
      end

      raise CFFormatError.new("unknown null type: $length")
    end

    # read a binary int value
    def read_binary_int(fname,fd,length)
      raise CFFormatError.new("Integer greater than 8 bytes: $length") if length > 3

      nbytes = 1 << length

      val = nil
      buff = fd.read(nbytes)

      case length
      when 0
        val = buff.unpack("C")
        val = val[0]
      when 1
        val = buff.unpack("n")
        val = val[0]
      when 2
        val = buff.unpack("N")
        val = val[0]
      when 3
        hiword,loword = buff.unpack("NN")
        val = hiword << 32 | loword
      end

      return CFInteger.new(val)
    end

    # read a binary real value
    def read_binary_real(fname,fd,length)
      raise CFFormatError.new("Real greater than 8 bytes: #{length}") if length > 3

      nbytes = 1 << length
      val = nil
      buff = fd.read(nbytes)

      case length
      when 0 #// 1 byte float? must be an error
        raise CFFormatError.new("got #{length+1} byte float, must be an error!")
      when 1 # 2 byte float? must be an error
        raise CFFormatError.new("got #{length+1} byte float, must be an error!")
      when 2
        val = buff.reverse.unpack("f")
        val = val[0]
      when 3
        val = buff.reverse.unpack("d")
        val = val[0]
      end

      return CFReal.new(val)
    end

    # read a binary date value
    def read_binary_date(fname,fd,length)
      raise CFFormatError.new("Date greater than 8 bytes: #{length}") if length > 3

      nbytes = 1 << length
      val = nil

      buff = fd.read(nbytes)

      case length
      when 0 # 1 byte CFDate is an error
        raise CFFormatError.new("#{length+1} byte CFDate, error")
      when 1 # 2 byte CFDate is an error
        raise CFFormatError.new("#{length+1} byte CFDate, error")
      when 2
        val = buff.reverse.unpack("f")
        val = val[0]
      when 3
        val = buff.reverse.unpack("d")
        val = val[0]
      end

      return CFDate.new(val,CFDate::TIMESTAMP_APPLE)
    end

    # read a binary data value
    def read_binary_data(fname,fd,length)
      buff = fd.read(length)
      return CFData.new(buff,CFData::DATA_RAW)
    end

    # read a binary string value
    def read_binary_string(fname,fd,length)
      buff = fd.read(length)

      @unique_table[buff] = true unless @unique_table.has_key?(buff)
      return CFString.new(buff)
    end

    # read a binary unicode string, i.e. a utf16be encoded string
    def read_binary_unicode_string(fname,fd,length)
      buff = fd.read(2*length)

      @unique_table[buff] = true unless @unique_table.has_key?(buff)
      return CFString.new(buff.force_encoding(Encoding.find("UTF-16BE")))
    end

    # read a binary coded array
    def read_binary_array(fname,fd,length)
      ary = Array.new

      # first: read object refs
      if(length != 0) then
        buff = fd.read(length * @object_ref_size)
        objects = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # now: read objects
        0.upto(length-1) do
          |i|
          object = read_binary_object_at(fname,fd,objects[i])
          ary.push object
        end
      end

      return CFArray.new(ary)
    end

    # read a binary coded dict
    def read_binary_dict(fname,fd,length)
      dict = Hash.new

      # first: read keys
      if(length != 0) then
        buff = fd.read(length * @object_ref_size)
        keys = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # second: read object refs
        buff = fd.read(length * @object_ref_size)
        objects = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # read real keys and objects
        0.upto(length-1) do
          |i|
          key = read_binary_object_at(fname,fd,keys[i])
          object = read_binary_object_at(fname,fd,objects[i])
          dict[key.value] = object
        end
      end

      return CFDictionary.new(dict)
    end

    # read a binary object; reads the type bytes and then calls the correct
    # reader
    def read_binary_object(fname,fd)
      # first: read the marker byte
      buff = fd.read(1)

      object_length = buff.unpack("C*")
      object_length = object_length[0]  & 0xF
      buff = buff.unpack("H*")
      buff = buff[0]

      object_type = buff[0]
      if(object_type != "0" && object_length == 15) then
        object_length = read_binary_object(fname,fd)
        object_length = object_length.value
      end

      retval = nil
      case object_type
      when '0' # null, false, true, fillbyte
        retval = read_binary_null_type(object_length)
      when '1' # integer
        retval = read_binary_int(fname,fd,object_length)
      when '2' # real
        retval = read_binary_real(fname,fd,object_length)
      when '3' # date
        retval = read_binary_date(fname,fd,object_length)
      when '4' # data
        retval = read_binary_data(fname,fd,object_length)
      when '5' # byte string, usually utf8 encoded
        retval = read_binary_string(fname,fd,object_length)
      when '6' # unicode string (utf16be)
        retval = read_binary_unicode_string(fname,fd,object_length)
      when 'a' # array
        retval = read_binary_array(fname,fd,object_length)
      when 'd' # dictionary
        retval = read_binary_dict(fname,fd,object_length)
      end

      return retval
    end

    # read a binary object at a defined position in the file; seeks and then calls read_binary_object
    def read_binary_object_at(file,fd,offset)
      position = @offsets[offset]
      fd.seek(position,IO::SEEK_SET)
      return read_binary_object(file,fd)
    end

    # read a binary file
    def read_binary(file)
      @unique_table = Hash.new
      @count_objects = 0
      @string_size = 0
      @int_size = 0
      @misc_size = 0
      @object_refs = 0

      @written_object_count = 0
      @object_table = Hash.new
      @object_ref_size = 0

      @offsets = Array.new

      fd = File.open(file,"rb")
      fd.seek(-32,IO::SEEK_END)

      buff = fd.read(32)
      offset_size, object_ref_size, number_of_objects, top_object, table_offset = buff.unpack "x6CCx4Nx4Nx4N"

      fd.seek(table_offset, IO::SEEK_SET)
      coded_offset_table = fd.read(number_of_objects * offset_size)

      @count_objects = number_of_objects

      formats = ["","C*","n*","(H6)*","N*"]
      @offsets = coded_offset_table.unpack(formats[offset_size])
      if(offset_size == 3) then
        0.upto(@offsets.count-1) do
          |i|
          @offsets[i] = @offsets[i].to_i(16)
        end
      end

      @unique_table = Hash.new
      @object_ref_size = object_ref_size
      top = read_binary_object_at(file,fd,top_object)

      @value = top

      fd.close
    end

    # read a XML file
    def read_xml(file)
      doc = LibXML::XML::Document.file(file,:options => LibXML::XML::Parser::Options::NOBLANKS|LibXML::XML::Parser::Options::NOENT)
      root = doc.root.first
      @value = importXML(root)
    end

    # get the value of a DOM node
    def get_value(n)
      return n.first.content if n.children?
      return n.content
    end

    # import the XML values
    def importXML(node)
      ret = nil

      case node.name
      when 'dict'
        hsh = Hash.new
        key = nil

        if node.children? then
          node.children.each do
            |n|

            if n.name == "key" then
              key = get_value(n)
            else
              raise CFFormatError.new("Format error!") if key.nil?
              hsh[key] = importXML(n)
              key = nil
            end
          end
        end

        ret = CFDictionary.new(hsh)

      when 'array'
        ary = Array.new

        if node.children? then
          node.children.each do
            |n|
            ary.push importXML(n)
          end
        end

        ret = CFArray.new(ary)

      when 'true'
        ret = CFBoolean.new(true)
      when 'false'
        ret = CFBoolean.new(false)
      when 'real'
        ret = CFReal.new(get_value(node).to_f)
      when 'integer'
        ret = CFInteger.new(get_value(node).to_i)
      when 'string'
        ret = CFString.new(get_value(node))
      when 'data'
        ret = CFData.new(get_value(node))
      when 'date'
        ret = CFDate.new(CFDate.parse_date(get_value(node)))
      end

      return ret
    end

end


# eof