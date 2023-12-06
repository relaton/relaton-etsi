describe RelatonEtsi::BibliographicItem do
  subject do
    docid = RelatonBib::DocumentIdentifier.new id: "ETSI EN 319 532-4 V1.3.0 (2023-10)", type: "ETSI", primary: true
    tc = RelatonBib::TechnicalCommittee.new RelatonBib::WorkGroup.new(name: "WG1")
    editorialgroup = RelatonBib::EditorialGroup.new [tc]
    doctype = RelatonEtsi::DocumentType.create_from_abbreviation "EN"
    described_class.new(
      id: "ETSIEN319532-4V1.3.02023-10",
      title: [{ content: "Title", language: "en", script: "Latn" }],
      docnumber: "ETSI EN 319 532-4 V1.3.0 (2023-10)",
      link: [{ type: "src", content: "http://webapp.etsi.org/workprogram/Report_WorkItem.asp?WKI_ID=62010" }],
      date: [{ type: "published", on: "2023-10" }], docid: [docid],
      version: [RelatonBib::BibliographicItem::Version.new(nil, "1.3.0")],
      status: RelatonBib::DocumentStatus.new(stage: "draft"),
      keyword: ["keyword"], editorialgroup: editorialgroup,
      doctype: doctype, abstract: [{ content: "abstract", language: "en", script: "Latn" }],
      language: ["en"], script: ["Latn"], marker: "Current", frequency: ["Annual"],
      mandate: ["M/123"], custom_collection: "HSs cited in OJ"
    )
  end

  it "initializes" do
    expect(subject).to be_instance_of RelatonEtsi::BibliographicItem
    expect(subject.marker).to eq "Current"
    expect(subject.frequency).to eq ["Annual"]
    expect(subject.mandate).to eq ["M/123"]
    expect(subject.custom_collection).to eq "HSs cited in OJ"
  end

  it "creates from hash" do
    hash = subject.to_hash
    item = RelatonEtsi::BibliographicItem.from_hash hash
    expect(item.to_hash).to eq hash
  end

  context "instance methods" do
    let(:schema) { Jing.new "grammars/relaton-etsi-compile.rng" }

    context "#to_xml" do
      it "without ext" do
        xml = subject.to_xml
        file = "spec/fixtures/bibitem.xml"
        File.write file, xml, encoding: "UTF-8"
        expect(xml).to_not include "<ext schema-version="
        expect(schema.validate(file)).to eq []
      end

      it "with ext" do
        xml = subject.to_xml bibdata: true
        file = "spec/fixtures/bibdata.xml"
        File.write file, xml, encoding: "UTF-8"
        expect(xml).to include "<ext schema-version="
        expect(xml).to include "<doctype abbreviation=\"EN\">European Standard</doctype>"
        expect(xml).to include "<marker>Current</marker>"
        expect(xml).to include "<frequency>Annual</frequency>"
        expect(xml).to include "<mandate>M/123</mandate>"
        expect(xml).to include "<custom-collection>HSs cited in OJ</custom-collection>"
        expect(schema.validate(file)).to eq []
      end
    end

    it "#to_hash" do
      hash = subject.to_hash
      file = "spec/fixtures/item_hash.yaml"
      File.write file, hash.to_yaml, encoding: "UTF-8"
      expect(hash["doctype"]["type"]).to eq "European Standard"
      expect(hash["doctype"]["abbreviation"]).to eq "EN"
      expect(hash["marker"]).to eq "Current"
      expect(hash["frequency"]).to eq ["Annual"]
      expect(hash["mandate"]).to eq ["M/123"]
      expect(hash["custom_collection"]).to eq "HSs cited in OJ"
    end

    it "#to_asciibib" do
      bib = subject.to_asciibib
      expect(bib).to include "marker:: Current"
      expect(bib).to include "frequency:: Annual"
      expect(bib).to include "mandate:: M/123"
      expect(bib).to include "custom_collection:: HSs cited in OJ"
    end
  end
end
