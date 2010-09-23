require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestOffsets < Test::Unit::TestCase
  include Reference
  
  def test_read_offsets_1_byte
    array = parsed_xml('offsets_1_byte')
    assert_equal 20, array.size
    0.upto(19) do |i|
      assert_equal i.to_s, array[i]
    end
    
    array = parsed_binary('offsets_1_byte')
    assert_equal 20, array.size
    0.upto(19) do |i|
      assert_equal i.to_s, array[i]
    end
  end
  
  def test_read_offsets_2_bytes
    array = parsed_xml('offsets_2_bytes')
    assert_equal 2, array.size
    prefix = '1234567890' * 30
    assert_equal "#{prefix}-0", array[0]
    assert_equal "#{prefix}-1", array[1]
    
    array = parsed_binary('offsets_2_bytes')
    assert_equal 2, array.size
    assert_equal "#{prefix}-0", array[0]
    assert_equal "#{prefix}-1", array[1]
  end
  
  def test_read_offsets_4_bytes
    array = parsed_xml('offsets_4_bytes')
    assert_equal 220, array.size
    prefix = '1234567890' * 30
    0.upto(219) do |i|
      assert_equal "#{prefix}-#{i}", array[i]
    end
    
    array = parsed_binary('offsets_4_bytes')
    assert_equal 220, array.size
    0.upto(219) do |i|
      assert_equal "#{prefix}-#{i}", array[i]
    end
  end
  
  def test_write_offsets_1_byte
    array = (0..19).collect { |i| i.to_s }
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(array)
    assert_equal raw_xml('offsets_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('offsets_1_byte'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
  
  def test_write_offsets_2_bytes
    prefix = '1234567890' * 30
    array = (0..1).collect { |i| "#{prefix}-#{i}" }
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(array)
    assert_equal raw_xml('offsets_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('offsets_2_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
  
  def test_write_offsets_4_bytes
    prefix = '1234567890' * 30
    array = (0..219).collect { |i| "#{prefix}-#{i}" }
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(array)
    assert_equal raw_xml('offsets_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_XML, :formatted => false)
    assert_equal raw_binary('offsets_4_bytes'), plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  end
end
