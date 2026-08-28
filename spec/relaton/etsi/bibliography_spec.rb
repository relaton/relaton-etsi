describe Relaton::Etsi::Bibliography do
  it "get for a document by docid", vcr: "search_doc" do
    expect do
      item = described_class.get "ETSI GS ZSM 012"
      expect(item).to be_instance_of Relaton::Etsi::ItemData
      expect(item.docidentifier.first.content).to eq "ETSI GS ZSM 012 V1.1.1 (2022-12)"
    end.to output(
      match(/\[relaton-etsi\] INFO: \(ETSI GS ZSM 012\) Fetching from Relaton repository \.\.\./).and(
        match(/\[relaton-etsi\] INFO: \(ETSI GS ZSM 012\) Found: `ETSI GS ZSM 012 V1.1.1 \(2022-12\)`/),
      ),
    ).to_stderr_from_any_process
  end

  it "raise network/server error" do
    expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect { described_class.get "ETSI GS ZSM 012" }.to raise_error Relaton::RequestError
  end

  it "not found" do
    expect do
      described_class.get "ETSI GS ZSM 011"
    end.to output(/\[relaton-etsi\] INFO: \(ETSI GS ZSM 011\) Not found\./).to_stderr_from_any_process
  end

  context "picks the newest edition" do
    def stub_data(file)
      url = "#{Relaton::Etsi::Bibliography::SOURCE}#{file}"
      stub_request(:get, url).to_return(status: 404)
    end

    it "for a bare reference" do
      stub = stub_data "data/etsi-en-319-401-v3-2-1-2026-01.yaml"
      described_class.search "ETSI EN 319 401"
      expect(stub).to have_been_requested
    end

    it "for a reference without the ETSI prefix" do
      stub = stub_data "data/etsi-en-319-401-v3-2-1-2026-01.yaml"
      described_class.search "EN 319 401"
      expect(stub).to have_been_requested
    end

    it "when the version has two digits" do
      stub = stub_data "data/etsi-ts-155-236-v19-0-0-2025-10.yaml"
      described_class.search "ETSI TS 155 236"
      expect(stub).to have_been_requested
    end

    it "when the edition has two digits" do
      stub = stub_data "data/etsi-ets-300-974-ed-11-2000-12.yaml"
      described_class.search "ETSI ETS 300 974"
      expect(stub).to have_been_requested
    end

    it "for a reference with a lower case prefix" do
      stub = stub_data "data/etsi-en-319-401-v3-2-1-2026-01.yaml"
      described_class.search "etsi EN 319 401"
      expect(stub).to have_been_requested
    end

    it "for a reference without a part number" do
      stub = stub_data "data/etsi-en-319-142-2-v1-2-1-2025-07.yaml"
      described_class.search "ETSI EN 319 142"
      expect(stub).to have_been_requested
    end

    it "when string order and version order disagree" do
      stub = stub_data "data/etsi-ts-124-229-v19-6-0-2026-03.yaml"
      described_class.search "ETSI TS 124 229"
      expect(stub).to have_been_requested
    end

    it "when the editions span many releases" do
      stub = stub_data "data/etsi-ts-129-571-v19-5-0-2026-02.yaml"
      described_class.search "ETSI TS 129 571"
      expect(stub).to have_been_requested
    end

    # A higher version wins over a later date. See `edition_key`.
    it "when an older release has a later date" do
      stub = stub_data "data/etsi-gs-cdm-002-v2-1-1-2023-02.yaml"
      described_class.search "ETSI GS CDM 002"
      expect(stub).to have_been_requested
    end

    it "for an exact reference" do
      stub = stub_data "data/etsi-en-319-401-v2-3-1-2021-05.yaml"
      described_class.search "ETSI EN 319 401 V2.3.1 (2021-05)"
      expect(stub).to have_been_requested
    end
  end

  context "rejects an incomplete document number" do
    it "when the number is truncated" do
      expect(described_class.search("ETSI TS 103 1")).to be_nil
    end

    it "when the last group of digits is truncated" do
      expect(described_class.search("ETSI EN 319 14")).to be_nil
    end

    it "when the number stops before the last group of digits" do
      expect(described_class.search("ETSI EN 319")).to be_nil
    end
  end
end
