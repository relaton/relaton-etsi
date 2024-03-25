describe RelatonEtsi::XMLParser do
  it "parses XML" do
    xml = File.read "spec/fixtures/bibdata.xml", encoding: "UTF-8"
    item = RelatonEtsi::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "create_doctype" do
    elm = Nokogiri::XML("<doctype abbreviation='EN'>European Standard</doctype>").at "doctype"
    dt = RelatonEtsi::XMLParser.send :create_doctype, elm
    expect(dt).to be_instance_of RelatonEtsi::DocumentType
    expect(dt.type).to eq "European Standard"
    expect(dt.abbreviation).to eq "EN"
  end
end
