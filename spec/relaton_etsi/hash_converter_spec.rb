describe RelatonEtsi::HashConverter do
  it "creates bibitem from hash" do
    expect(RelatonEtsi::BibliographicItem).to receive(:new).with(title: "title").and_return :item
    expect(described_class.send(:bib_item, title: "title")).to eq :item
  end

  it "create_doctype" do
    hash = { type: "European Standard", abbreviation: "ES" }
    dt = RelatonEtsi::DocumentType.new(**hash)
    expect(dt).to be_instance_of RelatonEtsi::DocumentType
    expect(dt.type).to eq "European Standard"
    expect(dt.abbreviation).to eq "ES"
  end
end
