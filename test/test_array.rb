require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestArray < Minitest::Test
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

  def test_big_array
    arr = []
    100.times do |i|
      elem = []

      500.times do |j|
        elem.push i.to_s + ': ' + j.to_s
      end

      arr.push elem
    end

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(arr)

    assert_equal raw_xml('big_array'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('big_array'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_deeply_nested_array_binary
    nested = "x"
    2000.times { nested = [nested] }

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(nested)
    binary = plist.to_str(CFPropertyList::List::FORMAT_BINARY)

    assert_raises CFFormatError do
      CFPropertyList::List.new(:data => binary)
    end
  end
end
