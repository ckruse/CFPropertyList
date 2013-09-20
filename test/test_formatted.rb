require 'test/unit'
require 'rubygems'
require 'cfpropertylist'

class TestFormatted < Test::Unit::TestCase
  def test_formatted_with_libxml
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::LibXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::guess({data: 'blah'})
    plist.formatted = true
    assert plist.to_str(CFPropertyList::List::FORMAT_XML) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_formatted_with_nokogiri
    require File.dirname(__FILE__) + '/../lib/rbNokogiriParser.rb'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::NokogiriXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::guess({data: 'blah'})
    plist.formatted = true

    assert plist.to_str(CFPropertyList::List::FORMAT_XML) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_formatted_with_rexml
    require File.dirname(__FILE__) + '/../lib/rbREXMLParser.rb'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::ReXMLParser]

    plist = CFPropertyList::List.new
    plist.value = CFPropertyList::guess({data: 'blah'})
    plist.formatted = true

    assert plist.to_str(CFPropertyList::List::FORMAT_XML) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end



  def test_formatted_with_libxml_and_datastructures
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::LibXMLParser]

    foo = { :foo => "foo", :bar => "bar", :baz => "baz" }
    assert foo.to_plist({:plist_format => CFPropertyList::List::FORMAT_XML, :formatted => true}) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_formatted_with_nokogiri_and_datastructures
    require File.dirname(__FILE__) + '/../lib/rbNokogiriParser.rb'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::NokogiriXMLParser]

    foo = { :foo => "foo", :bar => "bar", :baz => "baz" }
    assert foo.to_plist({:plist_format => CFPropertyList::List::FORMAT_XML, :formatted => true}) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_formatted_with_rexml_and_datastructures
    require File.dirname(__FILE__) + '/../lib/rbREXMLParser.rb'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::ReXMLParser]

    foo = { :foo => "foo", :bar => "bar", :baz => "baz" }
    assert foo.to_plist({:plist_format => CFPropertyList::List::FORMAT_XML, :formatted => true}) =~ /<plist.*\n\s+<dict>/m

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

end
