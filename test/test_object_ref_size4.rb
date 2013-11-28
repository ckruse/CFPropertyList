require 'test/unit'

require 'rubygems'
#gem 'libxml-ruby'

require 'cfpropertylist'
require 'reference'

class TestObjectRefSize4 < Test::Unit::TestCase
  include Reference

  def test_very_big_dict
    dict = parsed_binary('very_big_binary_dict')
    50000.times do |i|
      assert dict.has_key?('key' + i.to_s)
      assert_equal i.to_s, dict['key' + i.to_s]
    end
  end


  def test_very_big_array
    ary = parsed_binary('very_big_binary_array')
    100000.times do |i|
      assert_equal 'val' + i.to_s, ary[i]
    end
  end

end
