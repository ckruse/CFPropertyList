require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'test/reference'

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
    assert_equal "UTF-8 \xe2\x98\xbc", parsed_xml('string_utf8_short')
    assert_equal "UTF-8 \xe2\x98\xbc", parsed_binary('string_utf8_short')
  end
  
  def test_read_string_utf8_long
    assert_equal "long UTF-8 data with a 4-byte glyph \xf0\x90\x84\x82", parsed_xml('string_utf8_long')
    assert_equal "long UTF-8 data with a 4-byte glyph \xf0\x90\x84\x82", parsed_binary('string_utf8_long')
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
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess("UTF-8 \xe2\x98\xbc")
    assert_equal raw_xml('string_utf8_short'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_utf8_short'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
  
  def test_write_string_utf8_long
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess("long UTF-8 data with a 4-byte glyph \xf0\x90\x84\x82")
    assert_equal raw_xml('string_utf8_long'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('string_utf8_long'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
