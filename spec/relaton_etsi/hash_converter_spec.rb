describe RelatonEtsi::HashConverter do
  it "creates bibitem from hash" do
    expect(RelatonEtsi::BibliographicItem).to receive(:new).with(title: "title").and_return :item
    expect(described_class.send(:bib_item, title: "title")).to eq :item
  end
end
