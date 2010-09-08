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
end
