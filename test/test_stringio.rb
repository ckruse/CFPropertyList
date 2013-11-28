require 'test/unit'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestStringio < Test::Unit::TestCase
  include Reference

  def test_read_stringio
    plist = CFPropertyList::List.new(data: raw_binary('array'))
    assert_equal parsed_binary('array'), CFPropertyList.native_types(plist.value)
  end
end
