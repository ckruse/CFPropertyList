require 'test/unit'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestDate < Test::Unit::TestCase
  include Reference

  def test_read_date_epoch
    assert_equal Time.at(0), parsed_xml('date_epoch')
    assert_equal Time.at(0), parsed_binary('date_epoch')
  end

  def test_read_date_1900
    assert_equal Time.gm(1900, 1, 1, 12, 0, 0, 0), parsed_xml('date_1900')
    assert_equal Time.gm(1900, 1, 1, 12, 0, 0, 0), parsed_binary('date_1900')
  end

  def test_write_date_epoch
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(Time.at(0))
    assert_equal raw_xml('date_epoch'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('date_epoch'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_date_1900
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(Time.gm(1900, 1, 1, 12, 0, 0, 0))
    assert_equal raw_xml('date_1900'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('date_1900'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_date_from_date_object
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(Date.new(2011, 5, 12))
    assert_equal raw_xml('date_from_date'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)
    assert_equal raw_binary('date_from_date'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  def test_write_date_from_datetime_object
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(DateTime.new(2011, 5, 12, 3, 28, 1))
    assert_equal raw_xml('date_from_datetime'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)
    assert_equal raw_binary('date_from_datetime'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end

  # TODO
  def test_write_date_from_datetime_object
    #plist = CFPropertyList::List.new
    #plist.value = CFPropertyList.guess(DateTime.new(2011, 5, 12, 5, 28, 1, '+0200'))
    #assert_equal raw_xml('date_from_datetime'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)
    #assert_equal raw_binary('date_from_datetime'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
