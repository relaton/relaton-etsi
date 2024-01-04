describe RelatonEtsi::DataParser do
  let(:row) do
    row = double "row"
    row
  end

  subject { RelatonEtsi::DataParser.new row }

  it "initializes" do
    expect(subject.instance_variable_get(:@row)).to eq row
  end

  context "instance methods" do
    it "#parse" do
      expect(subject).to receive(:id).and_return :id
      expect(subject).to receive(:title).and_return :title
      expect(subject).to receive(:docnumber).and_return :docnumber
      expect(subject).to receive(:link).and_return :link
      expect(subject).to receive(:date).and_return :date
      expect(subject).to receive(:docid).and_return :docid
      expect(subject).to receive(:version).and_return :version
      expect(subject).to receive(:status).and_return :status
      expect(subject).to receive(:contributor).and_return :contributor
      expect(subject).to receive(:keyword).and_return :keyword
      expect(subject).to receive(:editorialgroup).and_return :editorialgroup
      expect(subject).to receive(:doctype).and_return :doctype
      expect(subject).to receive(:abstract).and_return :abstract
      expect(RelatonEtsi::BibliographicItem).to receive(:new).with(
        id: :id, title: :title, docnumber: :docnumber, link: :link, date: :date,
        docid: :docid, version: :version, status: :status, contributor: :contributor,
        keyword: :keyword, editorialgroup: :editorialgroup, doctype: :doctype,
        abstract: :abstract, language: ["en"], script: ["Latn"]
      ).and_return :bibitem
      expect(subject.parse).to eq :bibitem
    end

    it "#id" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(subject.id).to eq "ETSIEN319532-4V1.3.02023-10"
    end

    it "#pubid" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      pubid = subject.pubid
      expect(pubid).to be_instance_of RelatonEtsi::PubId
    end

    it "#title" do
      expect(row).to receive(:[]).with("title").and_return "Title"
      title = subject.title
      expect(title).to be_instance_of Array
      expect(title.first).to be_instance_of RelatonBib::TypedTitleString
      expect(title.first.title.content).to eq "Title"
    end

    it "#docnumber" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(subject.docnumber).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
    end

    it "#link" do
      expect(row).to receive(:[]).with("Details link").and_return "https://www.etsi.org/src"
      expect(row).to receive(:[]).with("PDF link").and_return "https://www.etsi.org/pdf"
      link = subject.link
      expect(link).to be_instance_of Array
      expect(link.first).to be_instance_of RelatonBib::TypedUri
      expect(link.first.content.to_s).to eq "https://www.etsi.org/src"
      expect(link.first.type).to eq "src"
      expect(link.last.content.to_s).to eq "https://www.etsi.org/pdf"
      expect(link.last.type).to eq "pdf"
    end

    it "#date" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      date = subject.date
      expect(date).to be_instance_of Array
      expect(date.first).to be_instance_of RelatonBib::BibliographicDate
      expect(date.first.on).to eq "2023-10"
    end

    it "#docid" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      docid = subject.docid
      expect(docid).to be_instance_of Array
      expect(docid.first).to be_instance_of RelatonBib::DocumentIdentifier
      expect(docid.first.id).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
    end

    it "#version" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      version = subject.version
      expect(version).to be_instance_of Array
      expect(version.first).to be_instance_of RelatonBib::BibliographicItem::Version
      expect(version.first.draft).to eq "1.3.0"
    end

    context "#status" do
      context "approved" do
        before do
          expect(row).to receive(:[]).with("Status").and_return "On Approval"
        end

        it "EN" do
          expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
          status = subject.status
          expect(status).to be_instance_of RelatonBib::DocumentStatus
          expect(status.stage.value).to eq "EN approval"
        end

        it "SG" do
          expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI SG 319 532-4 V1.3.0 (2023-10)"
          status = subject.status
          expect(status).to be_instance_of RelatonBib::DocumentStatus
          expect(status.stage.value).to eq "SG approval"
        end

        it "ES" do
          expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI ES 319 532-4 V1.3.0 (2023-10)"
          status = subject.status
          expect(status).to be_instance_of RelatonBib::DocumentStatus
          expect(status.stage.value).to eq "ES approval"
        end
      end

      it "#contributor" do
        contrib = subject.contributor
        expect(contrib).to be_instance_of Array
        expect(contrib.first).to be_instance_of RelatonBib::ContributionInfo
        expect(contrib.first.entity).to be_instance_of RelatonBib::Organization
        expect(contrib.first.entity.name.first.content).to eq "European Telecommunications Standards Institute"
        expect(contrib.first.entity.name.first.language).to eq ["en"]
        expect(contrib.first.entity.name.first.script).to eq ["Latn"]
        expect(contrib.first.entity.abbreviation.content).to eq "ETSI"
      end

      it "Published" do
        expect(row).to receive(:[]).with("Status").and_return("Published").twice
        status = subject.status
        expect(status).to be_instance_of RelatonBib::DocumentStatus
        expect(status.stage.value).to eq "Published"
      end
    end

    it "#keyword" do
      expect(row).to receive(:[]).with("Keywords").and_return "Keyword 1,Keyword 2"
      expect(subject.keyword).to eq ["Keyword 1", "Keyword 2"]
    end

    it "#editorialgroup" do
      expect(row).to receive(:[]).with("Technical body").and_return "WG 1"
      editorialgroup = subject.editorialgroup
      expect(editorialgroup).to be_instance_of RelatonBib::EditorialGroup
      expect(editorialgroup.technical_committee).to be_instance_of Array
      expect(editorialgroup.technical_committee[0]).to be_instance_of RelatonBib::TechnicalCommittee
      expect(editorialgroup.technical_committee[0].workgroup).to be_instance_of RelatonBib::WorkGroup
      expect(editorialgroup.technical_committee[0].workgroup.name).to eq "WG 1"
    end

    context "#doctype" do
      it "EN" do
        expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
        expect(subject.doctype.type).to eq "European Standard"
      end

      it "ES" do
        expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI ES 319 532-4 V1.3.0 (2023-10)"
        expect(subject.doctype.type).to eq "ETSI Standard"
      end
    end

    it "#abstract" do
      expect(row).to receive(:[]).with("Scope").and_return("Abstract").twice
      abstract = subject.abstract
      expect(abstract).to be_instance_of Array
      expect(abstract.first).to be_instance_of RelatonBib::FormattedString
      expect(abstract.first.content).to eq "Abstract"
    end
  end
end
