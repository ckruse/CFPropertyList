require 'minitest/autorun'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestInteger < Minitest::Test
  include Reference

  def test_read_1_byte
    assert_equal 1, parsed_xml('int_1_byte')
    assert_equal 1, parsed_binary('int_1_byte')
  end

  def test_read_2_bytes
    assert_equal 2**8, parsed_xml('int_2_bytes')
    assert_equal 2**8, parsed_binary('int_2_bytes')
  end

  def test_read_4_bytes
    assert_equal 2**16, parsed_xml('int_4_bytes')
    assert_equal 2**16, parsed_binary('int_4_bytes')
  end

  def test_read_8_bytes
    assert_equal 2**32, parsed_xml('int_8_bytes')
    assert_equal 2**32, parsed_binary('int_8_bytes')
  end

  def test_read_signed
    assert_equal -1, parsed_xml('int_signed')
    assert_equal -1, parsed_binary('int_signed')
  end

  def test_write_1_byte
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(1)
    assert_equal raw_xml('int_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('int_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_2_bytes
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(2**8)
    assert_equal raw_xml('int_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('int_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_4_bytes
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(2**16)
    assert_equal raw_xml('int_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('int_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_8_bytes
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(2**32)
    assert_equal raw_xml('int_8_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('int_8_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_signed
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(-1)
    assert_equal raw_xml('int_signed'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('int_signed'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
