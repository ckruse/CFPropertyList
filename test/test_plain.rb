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
end
