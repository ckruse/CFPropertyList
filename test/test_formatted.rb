require 'test/unit'
require 'rubygems'
require 'cfpropertylist'

class TestFormatted < Test::Unit::TestCase
  def test_formatted_with_default
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::guess({data: 'blah'})
    plist.formatted = true
    assert plist.to_str(CFPropertyList::List::FORMAT_XML) =~ /<plist.*\n\s+<dict>/m
  end
end
