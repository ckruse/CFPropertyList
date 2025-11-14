require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestPlain < Minitest::Test
  include Reference

  def test_string_ascii_short
    assert_equal "data", parsed_plain("string_ascii_short")
  end

  def test_string_ascii_long
    assert_equal "datadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadata", parsed_plain("string_ascii_long")
  end

  def test_int_signed
    assert_equal(-1, parsed_plain("int_signed"))
  end

  def test_int_8_bytes_unsigned
    assert_equal(9223372036854775808, parsed_plain("int_8_bytes_unsigned"))
  end

  def test_int_8_bytes
    assert_equal(4294967296, parsed_plain("int_8_bytes"))
  end

  def test_int_4_bytes
    assert_equal(65536, parsed_plain("int_4_bytes"))
  end

  def test_int_1_bytes
    assert_equal(1, parsed_plain("int_1_byte"))
  end

  def test_array
    assert_equal ["object"], parsed_plain("array")
    assert_equal ["val1", "val 2", 123, {"a b" => "b c", "c" => "d"}], parsed_plain("array1")
  end

  def test_dict
    assert_equal({ "a" => "b" }, parsed_plain("dictionary"))
    assert_equal({ "a" => "b", "complex key" => { "a" => "b", "d" => [ "de fg" ]} }, parsed_plain("dictionary1"))
  end

  def test_bool
    assert_equal true, parsed_plain("true")
    assert_equal false, parsed_plain("false")
  end

  def test_real
    assert_equal [1.32, -1.32], parsed_plain('real')
  end

  def test_date
    assert_equal Time.new(2015, 1, 2, 13, 10, 0, "+02:00"), parsed_plain('date')
  end

  def test_binary
    assert_equal "\x00\n", parsed_plain('binary')
  end

  def test_serialize
    plist = CFPropertyList::List.new

    plist.value = CFPropertyList.guess("data")
    assert_equal raw_plain("string_ascii_short"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess("datadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadata")
    assert_equal raw_plain("string_ascii_long"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(-1)
    assert_equal raw_plain("int_signed"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(9223372036854775808)
    assert_equal raw_plain("int_8_bytes_unsigned"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(4294967296)
    assert_equal raw_plain("int_8_bytes"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(65536)
    assert_equal raw_plain("int_4_bytes"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(1)
    assert_equal raw_plain("int_1_byte"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(["object"])
    assert_equal raw_plain("array"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(["val1", "val 2", 123, {"a b" => "b c", "c" => "d"}])
    assert_equal raw_plain("array1"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess({ "a" => "b" })
    assert_equal raw_plain("dictionary"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess({ "a" => "b", "complex key" => { "a" => "b", "d" => [ "de fg" ]} })
    assert_equal raw_plain("dictionary1"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(true)
    assert_equal raw_plain("true"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(false)
    assert_equal raw_plain("false"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess([1.32, -1.32])
    assert_equal raw_plain("real"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(Time.new(2015, 1, 2, 13, 10, 0, "+02:00"))
    assert_equal raw_plain("date"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    plist.value = CFPropertyList.guess(CFPropertyList::Blob.new("\x00\n"))
    assert_equal raw_plain("binary"), plist.to_str(CFPropertyList::List::FORMAT_PLAIN)
  end

  def test_string_with_backslash_roundtrip
    original = "foo\\bar"
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(original)
    plain = plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    reparsed = CFPropertyList::List.new(:data => plain, :format => CFPropertyList::List::FORMAT_PLAIN)
    result = CFPropertyList.native_types(reparsed.value)

    assert_equal original, result
  end

  def test_string_with_newline_roundtrip
    original = "foo\nbar"
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(original)
    plain = plist.to_str(CFPropertyList::List::FORMAT_PLAIN)

    reparsed = CFPropertyList::List.new(:data => plain, :format => CFPropertyList::List::FORMAT_PLAIN)
    result = CFPropertyList.native_types(reparsed.value)

    assert_equal original, result
  end
end
