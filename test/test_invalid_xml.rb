# -*- coding: utf-8 -*-

require 'test/unit'
require 'rubygems'
require 'cfpropertylist'

class TestInvalidXML < Test::Unit::TestCase
  def test_invalid_xml_with_libxml
    require File.dirname(__FILE__) + '/../lib/rbLibXMLParser.rb'
    orig_interface = CFPropertyList.xml_parser_interface
    CFPropertyList.xml_parser_interface = CFPropertyList::LibXMLParser

    xml = "<dict>"
    plist = CFPropertyList::List.new

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
    ensure
      CFPropertyList.xml_parser_interface = orig_interface
    end
  end

  def test_invalid_xml_with_nokogiri
    require File.dirname(__FILE__) + '/../lib/rbNokogiriParser.rb'
    orig_interface = CFPropertyList.xml_parser_interface
    CFPropertyList.xml_parser_interface = CFPropertyList::NokogiriXMLParser

    xml = "<dict>"
    plist = CFPropertyList::List.new

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
    ensure
      CFPropertyList.xml_parser_interface = orig_interface
    end
  end

  def test_invalid_xml_with_rexml
    require File.dirname(__FILE__) + '/../lib/rbREXMLParser.rb'
    orig_interface = CFPropertyList.xml_parser_interface
    CFPropertyList.xml_parser_interface = CFPropertyList::ReXMLParser

    xml = "<dict>"
    plist = CFPropertyList::List.new

    begin
      plist.load_xml_str(xml)
    rescue CFFormatError
    ensure
      CFPropertyList.xml_parser_interface = orig_interface
    end
  end


end
