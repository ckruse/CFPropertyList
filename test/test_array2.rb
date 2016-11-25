require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestArray < Minitest::Test
  include Reference

  def test_read_array2
    assert_equal [ ], parsed_xml('array2')
  end

end
