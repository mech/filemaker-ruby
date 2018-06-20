module XmlLoader
  def import_xml_as_string(filename)
    File.read(File.dirname(__FILE__) + '/responses/' + filename)
  end

  def fake_typhoeus_post(xml)
    Typhoeus.stub('http://example.com/fmi/xml/fmresultset.xml').and_return(
      Typhoeus::Response.new(code: 200, body: import_xml_as_string(xml))
    )
  end

  def fake_typhoeus_error(status_code)
    Typhoeus.stub('http://example.com/fmi/xml/fmresultset.xml').and_return(
      Typhoeus::Response.new(code: status_code)
    )
  end
end
