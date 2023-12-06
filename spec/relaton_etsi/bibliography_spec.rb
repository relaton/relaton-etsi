describe RelatonEtsi::Bibliography do
  it "get for a document by docid", vcr: "search_doc" do
    expect do
      item = described_class.get "ETSI GS ZSM 012"
      expect(item).to be_instance_of RelatonEtsi::BibliographicItem
      expect(item.docidentifier.first.id).to eq "ETSI GS ZSM 012 V1.1.1 (2022-12)"
    end.to output(
      match(/\[relaton-etsi\] \(ETSI GS ZSM 012\) Fetching from Relaton repository \.\.\./).and(
        match(/\[relaton-etsi\] \(ETSI GS ZSM 012\) Found: `ETSI GS ZSM 012 V1.1.1 \(2022-12\)`/)
      )
    ).to_stderr_from_any_process
  end

  it "raise network/server error" do
    expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect { described_class.get "ETSI GS ZSM 012" }.to raise_error RelatonBib::RequestError
  end

  it "not found" do
    expect do
      described_class.get "ETSI GS ZSM 011"
    end.to output(/\[relaton-etsi\] \(ETSI GS ZSM 011\) Not found\./).to_stderr_from_any_process
  end
end
