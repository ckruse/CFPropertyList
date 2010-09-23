require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestBoolean < Test::Unit::TestCase
  include Reference
  
  def test_read_true
    assert_equal true, parsed_xml('boolean_true')
    assert_equal true, parsed_binary('boolean_true')
  end
  
  def test_read_false
    assert_equal false, parsed_xml('boolean_false')
    assert_equal false, parsed_binary('boolean_false')
  end
  
  def test_write_true
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(true)
    assert_equal raw_xml('boolean_true'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('boolean_true'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
  
  def test_write_false
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(false)
    assert_equal raw_xml('boolean_false'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('boolean_false'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
