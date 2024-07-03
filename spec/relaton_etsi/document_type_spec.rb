describe RelatonEtsi::DocumentType do
  context "initializes" do
    it do
      doctype = described_class.new type: "European Standard"
      expect(doctype.type).to eq "European Standard"
    end

    it "invalid type" do
      expect do
        described_class.new type: "invalid"
      end.to output(/\[relaton-etsi\] WARN: invalid doctype: `invalid`/).to_stderr_from_any_process
    end

    it "invalid abbreviation" do
      expect do
        described_class.new type: "European Standard", abbreviation: "invalid"
      end.to output(/\[relaton-etsi\] WARN: invalid doctype abbreviation: `invalid`/).to_stderr_from_any_process
    end
  end

  it "creates from abbreviation" do
    doctype = described_class.create_from_abbreviation "EN"
    expect(doctype.type).to eq "European Standard"
  end
end
