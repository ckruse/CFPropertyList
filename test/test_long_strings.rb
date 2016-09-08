require 'minitest/autorun'

require 'rubygems'

require 'cfpropertylist'
require 'reference'

class TestLongStrings < Minitest::Test
  include Reference
  def test_very_long_string_with_libxml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbLibXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::LibXMLParser]

    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string>foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofo</string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)
    assert_equal example_data, lst.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_very_long_string_with_rexml
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbREXMLParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::ReXMLParser]

    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string>foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofo</string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)
    assert_equal example_data, lst.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)

  ensure
    CFPropertyList::List.parsers = orig_parsers
  end

  def test_very_long_string_with_nokogiri
    orig_parsers = CFPropertyList::List.parsers
    require 'cfpropertylist/rbNokogiriParser'
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::NokogiriXMLParser]

    example_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <string>foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofo</string>
</plist>
XML

    lst = CFPropertyList::List.new
    lst.load_str(example_data)
    assert_equal example_data, lst.to_str(CFPropertyList::List::FORMAT_XML, :formatted => true)
  ensure
    CFPropertyList::List.parsers = orig_parsers
  end
end
