module Reference
  def raw_xml(filename)
    data = File.new("test/reference/#{filename}.xml").read
    data.force_encoding('UTF-8') if data.respond_to?(:force_encoding)
  end
  
  def parsed_xml(filename)
    plist = CFPropertyList::List.new(:data => raw_xml(filename))
    CFPropertyList.native_types(plist.value)
  end
  
  def raw_binary(filename)
    data = File.new("test/reference/#{filename}.plist").read
    data.force_encoding('BINARY') if data.respond_to?(:force_encoding)
  end
  
  def parsed_binary(filename)
    plist = CFPropertyList::List.new(:data => raw_binary(filename))
    CFPropertyList.native_types(plist.value)
  end
end
