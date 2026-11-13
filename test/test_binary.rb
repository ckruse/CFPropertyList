# -*- coding: ascii-8bit -*-

require 'minitest/autorun'

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

  def test_shared_arrays
    objects = (1..40).map { |i| "\xA2" + [i, i].pack("n*") }
    plist = CFPropertyList::List.new
    plist.load_str(binary_plist(objects + ["\x09"]), CFPropertyList::List::FORMAT_BINARY)

    value = plist.value
    native = CFPropertyList.native_types(value)
    39.times do
      assert_same value.value[0], value.value[1]
      assert_same native[0], native[1]
      value = value.value[0]
      native = native[0]
    end
    assert_equal [true, true], native
  end

  def test_shared_dictionaries
    objects = (1..40).map { |i| "\xD2" + [41, 42, i, i].pack("n*") }
    plist = CFPropertyList::List.new
    plist.load_str(binary_plist(objects + ["\x09", "\x51a", "\x51b"]), CFPropertyList::List::FORMAT_BINARY)

    value = plist.value
    native = CFPropertyList.native_types(value)
    39.times do
      assert_same value.value["a"], value.value["b"]
      assert_same native["a"], native["b"]
      value = value.value["a"]
      native = native["a"]
    end
    assert_equal({"a" => true, "b" => true}, native)
  end

  def test_shared_strings
    plist = CFPropertyList::List.new
    plist.load_str(binary_plist(["\xA2" + [1, 1].pack("n*"), "\x51a"]), CFPropertyList::List::FORMAT_BINARY)

    native = CFPropertyList.native_types(plist.value)
    assert_equal ["a", "a"], native
    refute_same plist.value.value[0], plist.value.value[1]

    native[0] << "b"
    assert_equal "a", native[1]
  end

  def test_shared_data
    plist = CFPropertyList::List.new
    plist.load_str(binary_plist(["\xA2" + [1, 1].pack("n*"), "\x41a"]), CFPropertyList::List::FORMAT_BINARY)

    native = CFPropertyList.native_types(plist.value)
    assert_equal ["a", "a"], native
    refute_same plist.value.value[0], plist.value.value[1]

    plist.value.value[0].decoded_value << "b"
    assert_equal "a", plist.value.value[1].decoded_value
  end

  def test_shared_date_and_integer
    objects = ["\xA4" + [1, 1, 2, 2].pack("n*"), "\x33" + [0.0].pack("G"), "\x10\x2A"]
    plist = CFPropertyList::List.new
    plist.load_str(binary_plist(objects), CFPropertyList::List::FORMAT_BINARY)

    date = Time.at(CFPropertyList::CFDate::DATE_DIFF_APPLE_UNIX)
    assert_equal [date, date, 42, 42], CFPropertyList.native_types(plist.value)
    refute_same plist.value.value[0], plist.value.value[1]
    refute_same plist.value.value[0].value, plist.value.value[1].value
    refute_same plist.value.value[2], plist.value.value[3]
  end

  def test_shared_array_max_depth
    chain = (1..400).map { |i| "\xA1" + [i + 1].pack("n") }
    plist = CFPropertyList::List.new

    objects = ["\xA2" + [1, 402].pack("n*")] + chain + ["\x09", "\xA1" + [1].pack("n")]
    plist.load_str(binary_plist(objects), CFPropertyList::List::FORMAT_BINARY)
    assert_same plist.value.value[0], plist.value.value[1].value[0]

    objects = ["\xA2" + [1, 402].pack("n*")] + chain + ["\x09"] +
      (403..600).map { |i| "\xA1" + [i].pack("n") } + ["\xA1" + [1].pack("n")]
    error = assert_raises CFFormatError do
      plist.load_str(binary_plist(objects), CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Maximum depth exceeded/, error.message)
  end

  def test_circular_reference
    plist = CFPropertyList::List.new
    error = assert_raises CFFormatError do
      plist.load_str(binary_plist(["\xA1" + [1].pack("n"), "\xA1" + [0].pack("n")]), CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Circular reference/, error.message)
  end

  def test_overlapping_arrays
    objects = [
      "\xAF\x10\xC8" + (1..200).to_a.pack("n*"),
      "\xAF\x10\xC8" + ([201] * 200).pack("n*"),
      "\x09",
    ]

    plist = CFPropertyList::List.new
    error = assert_raises CFFormatError do
      plist.load_str(binary_plist(objects, [0] + [1] * 200 + [2]), CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Objects overlap/, error.message)
  end

  def test_overlapping_strings
    objects = [
      "\xAF\x10\xC8" + (1..200).to_a.pack("n*"),
      "\x5F\x11\x07\xD0" + "a" * 2000,
    ]

    plist = CFPropertyList::List.new
    error = assert_raises CFFormatError do
      plist.load_str(binary_plist(objects, [0] + [1] * 200), CFPropertyList::List::FORMAT_BINARY)
    end
    assert_match(/Objects overlap/, error.message)
  end

  private

  def binary_plist(objects, offset_indexes = (0...objects.size).to_a)
    data = "bplist00".dup
    offsets = objects.map do |object|
      offset = data.bytesize
      data << object
      offset
    end
    table_offset = data.bytesize

    data << offset_indexes.map { |i| offsets[i] }.pack("n*")
    data << [2, 2, offset_indexes.size, 0, table_offset].pack("x6CCx4Nx4Nx4N")
  end
end
