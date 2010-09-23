require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestReal < Test::Unit::TestCase
  include Reference
  
  def test_read_float
    assert_equal 1.5, parsed_xml('real_float')
    assert_equal 1.5, parsed_binary('real_float')
  end
  
  def test_read_double
    assert_equal 1.5, parsed_xml('real_double')
    assert_equal 1.5, parsed_binary('real_double')
  end
  
  def test_write_double
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(1.5)
    assert_equal raw_xml('real_double'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('real_double'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
