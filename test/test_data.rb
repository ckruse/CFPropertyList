require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

require 'stringio'

class TestData < Minitest::Test
  include Reference

  def test_read_data_short
    assert_equal 'data', parsed_xml('data_short')
    assert_equal 'data', parsed_binary('data_short')
  end

  def test_read_data_long_1_byte
    assert_equal 'data' * 4, parsed_xml('data_long_1_byte')
    assert_equal 'data' * 4, parsed_binary('data_long_1_byte')
  end

  def test_read_data_long_2_bytes
    assert_equal 'data' * 128, parsed_xml('data_long_2_bytes')
    assert_equal 'data' * 128, parsed_binary('data_long_2_bytes')
  end

  def test_read_data_long_2_bytes
    assert_equal 'data' * 16384, parsed_xml('data_long_4_bytes')
    assert_equal 'data' * 16384, parsed_binary('data_long_4_bytes')
  end

  def test_write_data_short
    data = StringIO.new('data')
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_short'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_short'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_data_long_1_byte
    data = StringIO.new('data' * 4)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_long_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_long_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_data_long_2_bytes
    data = StringIO.new('data' * 128)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_long_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_long_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_data_long_4_bytes
    data = StringIO.new('data' * 16384)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_long_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_long_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
