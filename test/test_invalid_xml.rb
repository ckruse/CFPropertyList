# -*- coding: utf-8 -*-

require 'test/unit'
require 'rubygems'
require 'cfpropertylist'

class TestInvalidXML < Test::Unit::TestCase
  def test_invalid_xml_with_libxml
    require 'cfpropertylist/rbLibXMLParser'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::LibXMLParser]

    xml = "<dict>"
    plist = CFPropertyList::List.new

    has_raised = false

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
      has_raised = true
    ensure
      CFPropertyList::List.parsers = orig_parsers
    end

    assert has_raised
  end

  def test_invalid_xml_with_nokogiri
    require 'cfpropertylist/rbNokogiriParser'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::NokogiriXMLParser]

    xml = "<dict>"
    plist = CFPropertyList::List.new

    has_raised = false

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
      has_raised = true
    ensure
      CFPropertyList::List.parsers = orig_parsers
    end

    assert has_raised
  end

  def test_invalid_xml_with_rexml
    require 'cfpropertylist/rbREXMLParser'
    orig_parsers = CFPropertyList::List.parsers
    CFPropertyList::List.parsers = [CFPropertyList::Binary, CFPropertyList::ReXMLParser]

    xml = "<dict>"
    plist = CFPropertyList::List.new

    has_raised = false

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
      has_raised = true
    ensure
      CFPropertyList::List.parsers = orig_parsers
    end

    assert has_raised
  end


end
