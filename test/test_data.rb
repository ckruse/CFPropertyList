require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'test/reference'

require 'stringio'

class TestData < Test::Unit::TestCase
  include Reference
  
  def test_read_data_short
    assert_equal 'data', parsed_xml('data_short')
    assert_equal 'data', parsed_binary('data_short')
  end
  
  def test_read_data_long
    assert_equal 'data' * 4, parsed_xml('data_long')
    assert_equal 'data' * 4, parsed_binary('data_long')
  end
  
  def test_write_data_short
    data = StringIO.new('data')
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_short'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_short'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
  
  def test_write_data_long
    data = StringIO.new('data' * 4)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    assert_equal raw_xml('data_long'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('data_long'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
