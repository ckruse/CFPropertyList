require 'test/unit'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestString < Test::Unit::TestCase
  include Reference

  def test_read_string_ascii_short
    assert_equal 'data', parsed_xml('string_ascii_short')
    assert_equal 'data', parsed_binary('string_ascii_short')
  end

  def test_read_string_ascii_long
    assert_equal 'data' * 4, parsed_xml('string_ascii_long')
    assert_equal 'data' * 4, parsed_binary('string_ascii_long')
  end

  def test_read_string_utf8_short
    string = "UTF-8 \xe2\x98\xbc"
    string.force_encoding('UTF-8') if string.respond_to?(:force_encoding)
    assert_equal string, parsed_xml('string_utf8_short')
    assert_equal string, parsed_binary('string_utf8_short')
  end

  def test_read_string_utf8_long
    string = "long UTF-8 data with a 4-byte glyph \xf0\x90\x84\x82"
    string.force_encoding('UTF-8') if string.respond_to?(:force_encoding)
    assert_equal string, parsed_xml('string_utf8_long')
    assert_equal string, parsed_binary('string_utf8_long')
  end

  def test_write_string_ascii_short
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess('data')
    assert_equal raw_xml('string_ascii_short'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_ascii_short'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_string_ascii_long
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess('data' * 4)
    assert_equal raw_xml('string_ascii_long'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_ascii_long'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_string_utf8_short
    string = "UTF-8 \xe2\x98\xbc"
    string.force_encoding('UTF-8') if string.respond_to?(:force_encoding)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(string)
    assert_equal raw_xml('string_utf8_short'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_utf8_short'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_string_utf8_long
    string = "long UTF-8 data with a 4-byte glyph \xf0\x90\x84\x82"
    string.force_encoding('UTF-8') if string.respond_to?(:force_encoding)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(string)
    assert_equal raw_xml('string_utf8_long'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_utf8_long'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
