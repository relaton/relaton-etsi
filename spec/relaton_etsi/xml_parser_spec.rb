describe RelatonEtsi::XMLParser do
  it "parses XML" do
    xml = File.read "spec/fixtures/bibdata.xml", encoding: "UTF-8"
    item = RelatonEtsi::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end
end
