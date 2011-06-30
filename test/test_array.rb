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

=begin
  def test_write_enumerator
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess([ "object" ].to_enum)
    assert_equal raw_xml('array'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('array'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
=end

  def test_big_array
    require 'mongo'
    arr = Marshal.load File.read('test/reference/yap_schedules.rb')
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(
      arr, :converter_method => :to_plist_item,:convert_unknown_to_string => true
    )
    assert_equal raw_xml('big_array'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
   #plist.to_str(CFPropertyList::List::FORMAT_BINARY)
    assert_equal raw_binary('big_array'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)

    # create files
    #File.open('big_array.xml', 'w') {|fh|
      #fh.write plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    #}
    #File.open('big_array.plist', 'w') {|fh|
      #fh.write plist.to_str(CFPropertyList::List::FORMAT_BINARY)
    #}
  end
end
