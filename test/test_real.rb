require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'test/reference'

class TestReal < Test::Unit::TestCase
  include Reference
  
  def test_read_real
    assert_equal 1.5, parsed_xml('real')
    assert_equal 1.5, parsed_binary('real')
  end
  
  def test_write_real
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(1.5)
    assert_equal raw_xml('real'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('real'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
