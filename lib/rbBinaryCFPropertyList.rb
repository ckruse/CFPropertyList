# -*- coding: utf-8 -*-
#
# CFPropertyList implementation
# parser class to read, manipulate and write binary property list files (plist(5)) as defined by Apple
#
# Author::    Christian Kruse (mailto:cjk@wwwtech.de)
# Copyright:: Copyright (c) 2010
# License::   Distributes under the same terms as Ruby

module CFPropertyList
  class Binary
    # Read a binary plist file
    def load(opts)
      @unique_table = {}
      @count_objects = 0
      @string_size = 0
      @int_size = 0
      @misc_size = 0
      @object_refs = 0

      @written_object_count = 0
      @object_table = []
      @object_ref_size = 0

      @offsets = []

      fd = nil
      if(opts.has_key?(:file)) then
        fd = File.open(opts[:file],"rb")
        file = opts[:file]
      else
        fd = StringIO.new(opts[:data],"rb")
        file = "<string>"
      end

      # first, we read the trailer: 32 byte from the end
      fd.seek(-32,IO::SEEK_END)
      buff = fd.read(32)

      offset_size, object_ref_size, number_of_objects, top_object, table_offset = buff.unpack "x6CCx4Nx4Nx4N"

      # after that, get the offset table
      fd.seek(table_offset, IO::SEEK_SET)
      coded_offset_table = fd.read(number_of_objects * offset_size)
      raise CFFormatError.new("#{file}: Format error!") unless coded_offset_table.bytesize == number_of_objects * offset_size

      @count_objects = number_of_objects

      # decode offset table
      formats = ["","C*","n*","(H6)*","N*"]
      @offsets = coded_offset_table.unpack(formats[offset_size])
      if(offset_size == 3) then
        0.upto(@offsets.count-1) { |i| @offsets[i] = @offsets[i].to_i(16) }
      end

      @object_ref_size = object_ref_size
      val = read_binary_object_at(file,fd,top_object)

      fd.close
      return val
    end


    # Convert CFPropertyList to binary format; since we have to count our objects we simply unique CFDictionary and CFArray
    def to_str(opts={})
      @unique_table = {}
      @count_objects = 0
      @string_size = 0
      @int_size = 0
      @misc_size = 0
      @object_refs = 0

      @written_object_count = 0
      @object_table = []
      @object_ref_size = 0

      @offsets = []

      binary_str = "bplist00"
      unique_and_count_values(opts[:root])

      @count_objects += @unique_table.count
      @object_ref_size = Binary.bytes_needed(@count_objects)

      file_size = @string_size + @int_size + @misc_size + @object_refs * @object_ref_size + 40
      offset_size = Binary.bytes_needed(file_size)
      table_offset = file_size - 32

      @object_table = []
      @written_object_count = 0
      @unique_table = {} # we needed it to calculate several values, but now we need an empty table

      opts[:root].to_binary(self)

      object_offset = 8
      offsets = []

      0.upto(@object_table.count-1) do |i|
        binary_str += @object_table[i]
        offsets[i] = object_offset
        object_offset += @object_table[i].bytesize
      end

      offsets.each do |offset|
        binary_str += Binary.pack_it_with_size(offset_size,offset)
      end

      binary_str += [offset_size, @object_ref_size].pack("x6CC")
      binary_str += [@count_objects].pack("x4N")
      binary_str += [0].pack("x4N")
      binary_str += [table_offset].pack("x4N")

      return binary_str
    end

    # read a „null” type (i.e. null byte, marker byte, bool value)
    def read_binary_null_type(length)
      case length
      when 0 then return 0 # null byte
      when 8 then return CFBoolean.new(false)
      when 9 then return CFBoolean.new(true)
      when 15 then return 15 # fill type
      end

      raise CFFormatError.new("unknown null type: #{length}")
    end
    protected :read_binary_null_type

    # read a binary int value
    def read_binary_int(fname,fd,length)
      raise CFFormatError.new("Integer greater than 8 bytes: #{length}") if length > 3

      nbytes = 1 << length

      val = nil
      buff = fd.read(nbytes)

      case length
      when 0 then
        val = buff.unpack("C")
        val = val[0]
      when 1 then
        val = buff.unpack("n")
        val = val[0]
      when 2 then
        val = buff.unpack("N")
        val = val[0]
      when 3
        hiword,loword = buff.unpack("NN")
        val = hiword << 32 | loword
      end

      return CFInteger.new(val);
    end
    protected :read_binary_int

    # read a binary real value
    def read_binary_real(fname,fd,length)
      raise CFFormatError.new("Real greater than 8 bytes: #{length}") if length > 3

      nbytes = 1 << length
      val = nil
      buff = fd.read(nbytes)

      case length
      when 0 then # 1 byte float? must be an error
        raise CFFormatError.new("got #{length+1} byte float, must be an error!")
      when 1 then # 2 byte float? must be an error
        raise CFFormatError.new("got #{length+1} byte float, must be an error!")
      when 2 then
        val = buff.reverse.unpack("f")
        val = val[0]
      when 3 then
        val = buff.reverse.unpack("d")
        val = val[0]
      end

      return CFReal.new(val)
    end
    protected :read_binary_real

    # read a binary date value
    def read_binary_date(fname,fd,length)
      raise CFFormatError.new("Date greater than 8 bytes: #{length}") if length > 3

      nbytes = 1 << length
      val = nil
      buff = fd.read(nbytes)

      case length
      when 0 then # 1 byte CFDate is an error
        raise CFFormatError.new("#{length+1} byte CFDate, error")
      when 1 then # 2 byte CFDate is an error
        raise CFFormatError.new("#{length+1} byte CFDate, error")
      when 2 then
        val = buff.reverse.unpack("f")
        val = val[0]
      when 3 then
        val = buff.reverse.unpack("d")
        val = val[0]
      end

      return CFDate.new(val,CFDate::TIMESTAMP_APPLE)
    end
    protected :read_binary_date

    # Read a binary data value
    def read_binary_data(fname,fd,length)
      buff = "";
      buff = fd.read(length) if length > 0
      return CFData.new(buff,CFData::DATA_RAW)
    end
    protected :read_binary_data

    # Read a binary string value
    def read_binary_string(fname,fd,length)
      buff = ""
      buff = fd.read(length) if length > 0

      @unique_table[buff] = true unless @unique_table.has_key?(buff)
      return CFString.new(buff)
    end
    protected :read_binary_string

    # Convert the given string from one charset to another
    def Binary.charset_convert(str,from,to="UTF-8")
      return str.clone.force_encoding(from).encode(to) if str.respond_to?("encode")
      return Iconv.conv(to,from,str)
    end

    # Count characters considering character set
    def Binary.charset_strlen(str,charset="UTF-8")
      return str.length if str.respond_to?("encode")

      str = Iconv.conv("UTF-8",charset,str) if charset != "UTF-8"
      return str.scan(/./mu).size
    end

    # Read a unicode string value, coded as UTF-16BE
    def read_binary_unicode_string(fname,fd,length)
      # The problem is: we get the length of the string IN CHARACTERS;
      # since a char in UTF-16 can be 16 or 32 bit long, we don't really know
      # how long the string is in bytes
      buff = fd.read(2*length)

      @unique_table[buff] = true unless @unique_table.has_key?(buff)
      return CFString.new(Binary.charset_convert(buff,"UTF-16BE","UTF-8"))
    end
    protected :read_binary_unicode_string

    # Read an binary array value, including contained objects
    def read_binary_array(fname,fd,length)
      ary = []

      # first: read object refs
      if(length != 0) then
        buff = fd.read(length * @object_ref_size)
        objects = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # now: read objects
        0.upto(length-1) do |i|
          object = read_binary_object_at(fname,fd,objects[i])
          ary.push object
        end
      end

      return CFArray.new(ary)
    end
    protected :read_binary_array

    # Read a dictionary value, including contained objects
    def read_binary_dict(fname,fd,length)
      dict = {}

      # first: read keys
      if(length != 0) then
        buff = fd.read(length * @object_ref_size)
        keys = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # second: read object refs
        buff = fd.read(length * @object_ref_size)
        objects = buff.unpack(@object_ref_size == 1 ? "C*" : "n*")

        # read real keys and objects
        0.upto(length-1) do |i|
          key = read_binary_object_at(fname,fd,keys[i])
          object = read_binary_object_at(fname,fd,objects[i])
          dict[key.value] = object
        end
      end

      return CFDictionary.new(dict)
    end
    protected :read_binary_dict

    # Read an object type byte, decode it and delegate to the correct reader function
    def read_binary_object(fname,fd)
      # first: read the marker byte
      buff = fd.read(1)

      object_length = buff.unpack("C*")
      object_length = object_length[0]  & 0xF

      buff = buff.unpack("H*")
      object_type = buff[0][0].chr

      if(object_type != "0" && object_length == 15) then
        object_length = read_binary_object(fname,fd)
        object_length = object_length.value
      end

      retval = nil
      case object_type
      when '0' then # null, false, true, fillbyte
        retval = read_binary_null_type(object_length)
      when '1' then # integer
        retval = read_binary_int(fname,fd,object_length)
      when '2' then # real
        retval = read_binary_real(fname,fd,object_length)
      when '3' then # date
        retval = read_binary_date(fname,fd,object_length)
      when '4' then # data
        retval = read_binary_data(fname,fd,object_length)
      when '5' then # byte string, usually utf8 encoded
        retval = read_binary_string(fname,fd,object_length)
      when '6' then # unicode string (utf16be)
        retval = read_binary_unicode_string(fname,fd,object_length)
      when 'a' then # array
        retval = read_binary_array(fname,fd,object_length)
      when 'd' then # dictionary
        retval = read_binary_dict(fname,fd,object_length)
      end

      return retval
    end
    protected :read_binary_object

    # Read an object type byte at position $pos, decode it and delegate to the correct reader function
    def read_binary_object_at(fname,fd,pos)
      position = @offsets[pos]
      fd.seek(position,IO::SEEK_SET)
      return read_binary_object(fname,fd)
    end
    protected :read_binary_object_at

    # calculate the bytes needed for a size integer value
    def Binary.bytes_size_int(int)
      nbytes = 0

      nbytes += 2 if int > 0xE # 2 bytes int
      nbytes += 2 if int > 0xFF # 3 bytes int
      nbytes += 2 if int > 0xFFFF # 5 bytes int

      return nbytes
    end

    # Calculate the byte needed for a „normal” integer value
    def Binary.bytes_int(int)
      nbytes = 1

      nbytes += 1 if int > 0xFF # 2 byte int
      nbytes += 2 if int > 0xFFFF # 4 byte int
      nbytes += 4 if int > 0xFFFFFFFF # 8 byte int
      nbytes += 7 if int < 0 # 8 byte int (since it is signed)

      return nbytes + 1 # one „marker” byte
    end

    # pack an +int+ of +nbytes+ with size
    def Binary.pack_it_with_size(nbytes,int)
      format = ["C", "n", "N", "N"][nbytes-1]

      if(nbytes == 3) then
        val = [int].pack(format)
        return val.slice(-3)
      end

      return [int].pack(format)
    end

    # calculate how many bytes are needed to save +count+
    def Binary.bytes_needed(count)
      nbytes = 0

      while count >= 1 do
        nbytes += 1
        count /= 256
      end

      return nbytes
    end

    # create integer bytes of +int+
    def Binary.int_bytes(int)
      intbytes = ""

      if(int > 0xFFFF) then
        intbytes = "\x12"+[int].pack("N") # 4 byte integer
      elsif(int > 0xFF) then
        intbytes = "\x11"+[int].pack("n") # 2 byte integer
      else
        intbytes = "\x10"+[int].pack("C") # 8 byte integer
      end

      return intbytes;
    end

    # Create a type byte for binary format as defined by apple
    def Binary.type_bytes(type,type_len)
      optional_int = ""

      if(type_len < 15) then
        type += sprintf("%x",type_len)
      else
        type += "f"
        optional_int = Binary.int_bytes(type_len)
      end

      return [type].pack("H*") + optional_int
    end

    # „unique” and count values. „Unique” means, several objects (e.g. strings)
    # will only be saved once and referenced later
    def unique_and_count_values(value)
      # no uniquing for other types than CFString and CFData
      if(value.is_a?(CFInteger) || value.is_a?(CFReal)) then
        val = value.value
        if(value.is_a?(CFInteger)) then
          @int_size += Binary.bytes_int(val)
        else
          @misc_size += 9 # 9 bytes (8 + marker byte) for real
        end

        @count_objects += 1
        return
      elsif(value.is_a?(CFDate)) then
        @misc_size += 9
        @count_objects += 1
        return
      elsif(value.is_a?(CFBoolean)) then
        @count_objects += 1
        @misc_size += 1
        return
      elsif(value.is_a?(CFArray)) then
        cnt = 0

        value.value.each do |v|
          cnt += 1
          unique_and_count_values(v)
          @object_refs += 1 # each array member is a ref
        end

        @count_objects += 1
        @int_size += Binary.bytes_size_int(cnt)
        @misc_size += 1 # marker byte for array
        return
      elsif(value.is_a?(CFDictionary)) then
        cnt = 0

        value.value.each_pair do |k,v|
          cnt += 1

          if(!@unique_table.has_key?(k))
            @unique_table[k] = 0
            @string_size += Binary.binary_strlen(k) + 1
            @int_size += Binary.bytes_size_int(Binary.charset_strlen(k,'UTF-8'))
          end

          @object_refs += 2 # both, key and value, are refs
          @unique_table[k] += 1
          unique_and_count_values(v)
        end

        @count_objects += 1
        @misc_size += 1 # marker byte for dict
        @int_size += Binary.bytes_size_int(cnt)
        return
      elsif(value.is_a?(CFData)) then
        val = value.decoded_value
        @int_size += Binary.bytes_size_int(val.length)
        @misc_size += val.length
        @count_objects += 1
        return
      end

      val = value.value
      if(!@unique_table.has_key?(val)) then
        @unique_table[val] = 0
        @string_size += Binary.binary_strlen(val) + 1
        @int_size += Binary.bytes_size_int(Binary.charset_strlen(val,'UTF-8'))
      end

      @unique_table[val] += 1
    end
    protected :unique_and_count_values

    # Counts the number of bytes the string will have when coded; utf-16be if non-ascii characters are present.
    def Binary.binary_strlen(val)
      val.each_byte do |b|
        if(b > 127) then
          val = Binary.charset_convert(val, 'UTF-8', 'UTF-16BE')
          return val.bytesize
        end
      end

      return val.bytesize
    end

    # Uniques and transforms a string value to binary format and adds it to the object table
    def string_to_binary(val)
      saved_object_count = -1

      unless(@unique_table.has_key?(val)) then
        saved_object_count = @written_object_count
        @written_object_count += 1

        @unique_table[val] = saved_object_count
        utf16 = false

        val.each_byte do |b|
          if(b > 127) then
            utf16 = true
            break
          end
        end

        if(utf16) then
          bdata = Binary.type_bytes("6",Binary.charset_strlen(val,"UTF-8")) # 6 is 0110, unicode string (utf16be)
          val = Binary.charset_convert(val,"UTF-8","UTF-16BE")

          val.force_encoding("ASCII-8BIT") if val.respond_to?("encode")
          @object_table[saved_object_count] = bdata + val
        else
          bdata = Binary.type_bytes("5",val.bytesize) # 5 is 0101 which is an ASCII string (seems to be ASCII encoded)
          @object_table[saved_object_count] = bdata + val
        end
      else
        saved_object_count = @unique_table[val]
      end

      return saved_object_count
    end

    # Codes an integer to binary format
    def int_to_binary(value)
      nbytes = 0
      nbytes = 1 if value > 0xFF # 1 byte integer
      nbytes += 1 if value > 0xFFFF # 4 byte integer
      nbytes += 1 if value > 0xFFFFFFFF # 8 byte integer
      nbytes = 3 if value < 0 # 8 byte integer, since signed

      bdata = Binary.type_bytes("1", nbytes) # 1 is 0001, type indicator for integer
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
        # 64 bit signed integer; we need the higher and the lower 32 bit of the value
        high_word = value >> 32
        low_word = value & 0xFFFFFFFF
        buff = [high_word,low_word].pack("NN")
      end

      return bdata + buff
    end

    # Codes a real value to binary format
    def real_to_binary(val)
      bdata = Binary.type_bytes("2",3) # 2 is 0010, type indicator for reals
      buff = [val].pack("d")
      return bdata + buff.reverse
    end

    # Converts a numeric value to binary and adds it to the object table
    def num_to_binary(value)
      saved_object_count = @written_object_count
      @written_object_count += 1

      val = ""
      if(value.is_a?(CFInteger)) then
        val = int_to_binary(value.value)
      else
        val = real_to_binary(value.value)
      end

      @object_table[saved_object_count] = val
      return saved_object_count
    end

    # Convert date value (apple format) to binary and adds it to the object table
    def date_to_binary(val)
      saved_object_count = @written_object_count
      @written_object_count += 1

      val = val.getutc.to_f - CFDate::DATE_DIFF_APPLE_UNIX # CFDate is a real, number of seconds since 01/01/2001 00:00:00 GMT

      bdata = Binary.type_bytes("3", 3) # 3 is 0011, type indicator for date
      @object_table[saved_object_count] = bdata + [val].pack("d").reverse

      return saved_object_count
    end

    # Convert a bool value to binary and add it to the object table
    def bool_to_binary(val)
      saved_object_count = @written_object_count
      @written_object_count += 1

      @object_table[saved_object_count] = val ? "\x9" : "\x8" # 0x9 is 1001, type indicator for true; 0x8 is 1000, type indicator for false
      return saved_object_count
    end

    # Convert data value to binary format and add it to the object table
    def data_to_binary(val)
      saved_object_count = @written_object_count
      @written_object_count += 1

      bdata = Binary.type_bytes("4", val.bytesize) # a is 1000, type indicator for data
      @object_table[saved_object_count] = bdata + val

      return saved_object_count
    end

    # Convert array to binary format and add it to the object table
    def array_to_binary(val)
      saved_object_count = @written_object_count
      @written_object_count += 1

      bdata = Binary.type_bytes("a", val.value.count) # a is 1010, type indicator for arrays

      val.value.each do |v|
        bdata += Binary.pack_it_with_size(@object_ref_size,  v.to_binary(self));
      end

      @object_table[saved_object_count] = bdata
      return saved_object_count
    end

    # Convert dictionary to binary format and add it to the object table
    def dict_to_binary(val)
      saved_object_count = @written_object_count
      @written_object_count += 1

      bdata = Binary.type_bytes("d",val.value.count) # d=1101, type indicator for dictionary

      val.value.each_key do |k|
        str = CFString.new(k)
        key = str.to_binary(self)
        bdata += Binary.pack_it_with_size(@object_ref_size,key)
      end

      val.value.each_value do |v|
        bdata += Binary.pack_it_with_size(@object_ref_size,v.to_binary(self))
      end

      @object_table[saved_object_count] = bdata
      return saved_object_count
    end
  end
end

# eof
