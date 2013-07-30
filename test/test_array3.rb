require 'test/unit'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestArray < Test::Unit::TestCase
  include Reference

  def test_read_array
    assert_equal [ ], parsed_xml('array3')
  end

end
