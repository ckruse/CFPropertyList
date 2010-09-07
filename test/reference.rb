module Reference
  def raw_xml(filename)
    File.new("test/reference/#{filename}.xml").read
  end
  
  def parsed_xml(filename)
    plist = CFPropertyList::List.new(:data => raw_xml(filename))
    CFPropertyList.native_types(plist.value)
  end
  
  def raw_binary(filename)
    File.new("test/reference/#{filename}.plist").read
  end
  
  def parsed_binary(filename)
    plist = CFPropertyList::List.new(:data => raw_binary(filename))
    CFPropertyList.native_types(plist.value)
  end
end
