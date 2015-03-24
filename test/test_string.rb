require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestString < Minitest::Test
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

  def test_binary_data_blob
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(CFPropertyList::Blob.new('binary_data'))
    # These tests are failing because there are backslashes in the plists, and
    # I don't know how to escape them properly to work with your methods.
    assert_equal raw_binary('string_binary_data'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
    assert_equal raw_xml('string_binary_data').gsub(/\s/, ''), plist.to_str(CFPropertyList::List::FORMAT_XML).gsub(/\s/, '')
  end

  def test_empty_xml_string_with_libxml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbLibXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::LibXMLParser]
    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string></string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)

    assert_equal "", lst.value.value

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_empty_xml_string_with_rexml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbREXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::ReXMLParser]
    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string></string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)

    assert_equal "", lst.value.value

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_empty_xml_string_with_nokogiri
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbNokogiriParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::NokogiriXMLParser]
    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string></string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)

    assert_equal "", lst.value.value
  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_data_string_is_blob
    assert_equal parsed_binary('string_binary_data').class, CFPropertyList::Blob
    assert_equal parsed_xml('string_binary_data').class, CFPropertyList::Blob
  end

  def test_symbol_converts_to_string
    obj = CFPropertyList.guess(:test)
    assert obj.is_a?(CFPropertyList::CFString)

    obj = CFPropertyList.guess([:test])
    assert obj.value.first.is_a?(CFPropertyList::CFString)

    obj = CFPropertyList.guess({:test => :value})
    assert obj.value.values.first.is_a?(CFPropertyList::CFString)
    assert obj.value.keys.first.is_a?(String)
  end

end
