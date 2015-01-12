require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestUid < Minitest::Test
  include Reference

  def test_auto_detect_plain
    plist = CFPropertyList::List.new(:file => "test/reference/string_ascii_short.plain.plist")
    assert_equal "data", CFPropertyList.native_types(plist.value)
  end

  def test_auto_detect_xml
    plist = CFPropertyList::List.new(:file => "test/reference/array.xml")
    assert_equal [ "object" ], CFPropertyList.native_types(plist.value)
  end

  def test_auto_detect_binary
    plist = CFPropertyList::List.new(:file => "test/reference/array.plist")
    assert_equal [ "object" ], CFPropertyList.native_types(plist.value)
  end

  def test_auto_detect_plain_data
    plist = CFPropertyList::List.new(:data => IO.read("test/reference/string_ascii_short.plain.plist"))
    assert_equal "data", CFPropertyList.native_types(plist.value)
  end

  def test_auto_detect_xml_data
    plist = CFPropertyList::List.new(:data => IO.read("test/reference/array.xml"))
    assert_equal [ "object" ], CFPropertyList.native_types(plist.value)
  end

  def test_auto_detect_binary
    plist = CFPropertyList::List.new(:data => IO.read("test/reference/array.plist"))
    assert_equal [ "object" ], CFPropertyList.native_types(plist.value)
  end
end
