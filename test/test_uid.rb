require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestUid < Minitest::Test
  include Reference

  def test_parse_binary
    assert_equal 4129, parsed_binary('uid')
  end

  def test_parse_xml_rexml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbREXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::ReXMLParser]

    assert_equal 4129, parsed_xml('uid')

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_parse_xml_libxml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbLibXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::LibXMLParser]

    assert_equal 4129, parsed_xml('uid')

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_parse_xml_nokogiri
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbNokogiriParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::NokogiriXMLParser]

    assert_equal 4129, parsed_xml('uid')

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_write_binary
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::CFUid.new(4129)

    assert_equal plist.to_str(CFPropertyList::List::FORMAT_BINARY), raw_binary('uid')
  end

  def test_write_xml_rexml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbREXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::ReXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::CFUid.new(4129)

    assert_equal plist.to_str(CFPropertyList::List::FORMAT_XML).gsub(/\s+/, ''), raw_xml('uid').gsub(/\s+/, '')
  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_write_xml_libxml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbLibXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::LibXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::CFUid.new(4129)

    assert_equal plist.to_str(CFPropertyList::List::FORMAT_XML).gsub(/\s+/, ''), raw_xml('uid').gsub(/\s+/, '')
  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_write_xml_nokogiri
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbNokogiriParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary,
      CFPropertyList::NokogiriXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::CFUid.new(4129)

    assert_equal plist.to_str(CFPropertyList::List::FORMAT_XML).gsub(/\s+/, ''), raw_xml('uid').gsub(/\s+/, '')
  ensure
    CFPropertyList::List.parsers = orig_parsers
  end
end
