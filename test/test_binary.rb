# -*- coding: ascii-8bit -*-

require 'test/unit'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'

class TestBinary < Test::Unit::TestCase
  def test_pack_it_with_size
    assert_equal "\xFF", CFPropertyList::Binary.pack_it_with_size(1, 0xFF)
    assert_equal "\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(2, 0xFFFF)
    assert_equal "\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(4, 0xFFFFFFFF)
    assert_equal "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(8, 0x7FFFFFFFFFFFFFFF)
    assert_equal "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.pack_it_with_size(8, -1)
    assert_raise CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(3, 0)
    end
    assert_raise CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(5, 0)
    end
    assert_raise CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(6, 0)
    end
    assert_raise CFFormatError do
      CFPropertyList::Binary.pack_it_with_size(7, 0)
    end
  end

  def test_bytes_needed
    assert_equal 1, CFPropertyList::Binary.bytes_needed(1)
    assert_equal 2, CFPropertyList::Binary.bytes_needed(2**8)
    assert_equal 4, CFPropertyList::Binary.bytes_needed(2**16)
    assert_equal 4, CFPropertyList::Binary.bytes_needed(2**24)
    assert_equal 8, CFPropertyList::Binary.bytes_needed(2**32)
    assert_equal 8, CFPropertyList::Binary.bytes_needed(2**63)
    assert_raise CFFormatError do
      CFPropertyList::Binary.bytes_needed(2**64)
    end
  end
end
