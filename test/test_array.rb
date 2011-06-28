require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestArray < Test::Unit::TestCase
  include Reference
  
  def test_read_array
    assert_equal [ "object" ], parsed_xml('array')
    assert_equal [ "object" ], parsed_binary('array')
  end
  
  def test_write_array
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess([ "object" ])
    assert_equal raw_xml('array'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('array'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_enumerator
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess([ "object" ].to_enum)
    assert_equal raw_xml('array'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('array'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
