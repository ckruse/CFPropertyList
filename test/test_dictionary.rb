require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'test/reference'

class TestDictionary < Test::Unit::TestCase
  include Reference
  
  def test_read_dictionary
    assert_equal({ "key" => "value" }, parsed_xml('dictionary'))
    assert_equal({ "key" => "value" }, parsed_binary('dictionary'))
  end
  
  def test_write_dictionary
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess({ "key" => "value" })
    assert_equal raw_xml('dictionary'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('dictionary'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
