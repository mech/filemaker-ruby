module XmlLoader
  def import_xml_as_string(filename)
    File.read(File.dirname(__FILE__) + '/responses/' + filename)
  end
end
