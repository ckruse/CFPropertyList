require 'test/unit'

require 'rubygems'
gem 'libxml-ruby'

require 'cfpropertylist'

class TestBinary < Test::Unit::TestCase
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
  
  def test_int_bytes
    assert_equal "\x10\xFF", CFPropertyList::Binary.int_bytes(0xFF)
    assert_equal "\x11\xFF\xFF", CFPropertyList::Binary.int_bytes(0xFFFF)
    assert_equal "\x12\xFF\xFF\xFF\xFF", CFPropertyList::Binary.int_bytes(0xFFFFFFFF)
    assert_equal "\x13\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.int_bytes(0x7FFFFFFFFFFFFFFF)
    assert_equal "\x13\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", CFPropertyList::Binary.int_bytes(-1)
    assert_raise CFFormatError do
      CFPropertyList::Binary.int_bytes(0x8000000000000000)
    end
  end
end
