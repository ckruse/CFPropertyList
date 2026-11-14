# -*- coding: ascii-8bit -*-

require 'minitest/autorun'
require 'tempfile'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestBinary < Minitest::Test
  def test_pack_it_with_size
    assert_equal "\xFF", CFPropertyList::Binary.pack_it_with_size(1, 0xFF)
    assert_equal "\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(2, 0xFFFF)
    assert_equal "\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(4, 0xFFFFFFFF)
    assert_equal "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(8, 0x7FFFFFFFFFFFFFFF)
    assert_equal "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(8, -1)
    assert_raises CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(3, 0)
    end
    assert_raises CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(5, 0)
    end
    assert_raises CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(6, 0)
    end
    assert_raises CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(7, 0)
    end
  end

  def test_bytes_needed
    assert_equal 1, CFPropertyList::Binary.bytes_needed(1)
    assert_equal 2, CFPropertyList::Binary.bytes_needed(2**8)
    assert_equal 4, CFPropertyList::Binary.bytes_needed(2**16)
    assert_equal 4, CFPropertyList::Binary.bytes_needed(2**24)
    assert_equal 8, CFPropertyList::Binary.bytes_needed(2**32)
    assert_equal 8, CFPropertyList::Binary.bytes_needed(2**63)
    assert_raises CFFormatError do
      CFPropertyList::Binary.bytes_needed(2**64)
    end
  end

  def test_length_overflow
    header = "bplist00"
    offset_table = "\x08"
    plist = CFPropertyList::List.new

    ["\x4F", "\x5F", "\x6F", "\xAF", "\xDF"].each do |marker|
      object = marker + "\x11\x03\xE8"
      trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,12].pack("C*")

      error = assert_raises CFFormatError do
        plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
      end
      assert_match(/Invalid length 1000/, error.message)
    end
  end

  def test_length_overflow_in_file
    header = "bplist00"
    object = "\x4F\x11\x03\xE8"
    offset_table = "\x08"
    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,12].pack("C*")

    Tempfile.create("length") do |file|
      file.binmode
      file.write(header + object + offset_table + trailer)
      file.close

      plist = CFPropertyList::List.new
      error = assert_raises CFFormatError do
        plist.load(file.path, CFPropertyList::List::FORMAT_BINARY)
      end
      assert_match(/Invalid length 1000/, error.message)
    end
  end

  def test_length_up_to_end_of_file
    header = "bplist00"
    offset_table = "\x08"
    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,11].pack("C*")

    plist = CFPropertyList::List.new
    plist.load_str(header + "\x4F\x10\x21" + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    assert_equal offset_table + trailer, plist.value.decoded_value

    assert_raises CFFormatError do
      plist.load_str(header + "\x4F\x10\x22" + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    end
  end

  def test_length_is_not_an_integer
    header = "bplist00"
    offset_table = "\x08"
    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,10].pack("C*")
    plist = CFPropertyList::List.new

    ["\x5F\x09", "\x5F\x00", "\x5F\xA0"].each do |object|
      error = assert_raises CFFormatError do
        plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
      end
      assert_match(/Invalid length/, error.message)
    end
  end

  def test_nested_length_markers
    header = "bplist00"
    object = "\x5F" * 100_000
    offset_table = "\x08"
    trailer = [1, 1, 1, 0, 100_008].pack("x6CCx4Nx4Nx4N")

    plist = CFPropertyList::List.new
    error = assert_raises CFFormatError do
      plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Invalid length/, error.message)
  end

  def test_number_of_objects_overflow
    header = "bplist00"
    object = "\x09"
    offset_table = "\x08"
    plist = CFPropertyList::List.new

    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,33, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,9].pack("C*")
    plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    assert_equal true, plist.value.value

    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,34, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,9].pack("C*")
    error = assert_raises CFFormatError do
      plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Invalid number of objects 34/, error.message)
  end

  def test_invalid_offset_size
    header = "bplist00"
    object = "\x08"
    offset_table = "\x00"
    trailer = [0,0,0,0,0,0, 5, 1, 0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,9].pack("C*")

    plist = CFPropertyList::List.new
    assert_raises CFFormatError do
      plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    end
  end

  def test_offset_table_overflow
    header = "bplist00"
    object = "\x08"
    offset_table = "\x00" * 10
    trailer = [0,0,0,0,0,0, 1, 1, 0,0,0,0, 0,0,0,20, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0].pack("C*")

    plist = CFPropertyList::List.new
    assert_raises CFFormatError do
      plist.load_str(header + object + offset_table + trailer, CFPropertyList::List::FORMAT_BINARY)
    end
  end
end
