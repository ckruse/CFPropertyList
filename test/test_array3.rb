require 'minitest/autorun'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestArray < Minitest::Test
  include Reference

  def test_read_array3
    assert_equal [ ], parsed_xml('array3')
  end

end
