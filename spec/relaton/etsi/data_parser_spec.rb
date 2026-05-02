require "relaton/etsi/data_parser"

describe Relaton::Etsi::DataParser do
  let(:row) do
    row = double "row"
    row
  end

  subject { described_class.new row }

  it "initializes" do
    expect(subject.instance_variable_get(:@row)).to eq row
  end

  context "instance methods" do
    context "#parse" do
      let(:row) do
        {
          "ETSI deliverable" => "ETSI EN 319 532-4 V1.3.0 (2023-10)",
          "title" => "Electronic Signatures and Infrastructures (ESI); Registered Electronic Mail (REM) Services",
          "Details link" => "https://www.etsi.org/deliver/etsi_en/319500_319599/31953204/01.03.00_60/",
          "PDF link" => "https://www.etsi.org/deliver/etsi_en/319500_319599/31953204/01.03.00_60/en_31953204v010300p.pdf",
          "Status" => "Published",
          "Keywords" => "electronic signature,e-mail,registered electronic mail",
          "Technical body" => "ESI",
          "Scope" => "The present document specifies interoperability profiles for REM services.",
        }
      end

      subject { described_class.new(row).parse }

      it "returns a BibliographicItem" do
        expect(subject).to be_instance_of Relaton::Etsi::ItemData
      end

      it "has correct type" do
        expect(subject.type).to eq "standard"
      end

      it "has correct id" do
        expect(subject.id).to eq "ETSIEN3195324V130202310"
      end

      it "has correct title" do
        expect(subject.title).to be_instance_of Array
        expect(subject.title.first).to be_instance_of Relaton::Bib::Title
        expect(subject.title.first.content).to eq "Electronic Signatures and Infrastructures (ESI); Registered Electronic Mail (REM) Services"
      end

      it "has correct docnumber" do
        expect(subject.docnumber).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      end

      it "has correct source" do
        expect(subject.source).to be_instance_of Array
        expect(subject.source.size).to eq 2
        expect(subject.source[0]).to be_instance_of Relaton::Bib::Uri
        expect(subject.source[0].type).to eq "src"
        expect(subject.source[0].content.to_s).to eq "https://www.etsi.org/deliver/etsi_en/319500_319599/31953204/01.03.00_60/"
        expect(subject.source[1]).to be_instance_of Relaton::Bib::Uri
        expect(subject.source[1].type).to eq "pdf"
      end

      it "has correct date" do
        expect(subject.date).to be_instance_of Array
        expect(subject.date.first).to be_instance_of Relaton::Bib::Date
        expect(subject.date.first.type).to eq "published"
        expect(subject.date.first.at.to_s).to eq "2023-10"
      end

      it "has correct docid" do
        expect(subject.docidentifier).to be_instance_of Array
        expect(subject.docidentifier.first).to be_instance_of Relaton::Bib::Docidentifier
        expect(subject.docidentifier.first.content).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
        expect(subject.docidentifier.first.type).to eq "ETSI"
        expect(subject.docidentifier.first.primary).to be true
      end

      it "has correct version" do
        expect(subject.version).to be_instance_of Array
        expect(subject.version.first).to be_instance_of Relaton::Bib::Version
        expect(subject.version.first.draft).to eq "1.3.0"
      end

      it "has correct status" do
        expect(subject.status).to be_instance_of Relaton::Etsi::Status
        expect(subject.status.stage).to eq "Published"
      end

      it "has correct contributor" do
        expect(subject.contributor).to be_instance_of Array
        expect(subject.contributor.first).to be_instance_of Relaton::Bib::Contributor
        expect(subject.contributor.first.organization).to be_instance_of Relaton::Bib::Organization
        expect(subject.contributor.first.organization.name.first.content).to eq "European Telecommunications Standards Institute"
        expect(subject.contributor.first.organization.abbreviation.content).to eq "ETSI"
        expect(subject.contributor.first.role.first.type).to eq "publisher"
      end

      it "has correct keyword" do
        expect(subject.keyword).to be_instance_of Array
        expect(subject.keyword.first).to be_instance_of Relaton::Bib::Keyword
        expect(subject.keyword.map { |k| k.vocab.content }).to eq ["electronic signature", "e-mail", "registered electronic mail"]
      end

      it "has committee contributor for technical body" do
        committee = subject.contributor[1]
        expect(committee).to be_instance_of Relaton::Bib::Contributor
        expect(committee.role.first.type).to eq "author"
        expect(committee.role.first.description.first.content).to eq "committee"
        subdivision = committee.organization.subdivision.first
        expect(subdivision.name.first.content).to eq "ESI"
        expect(subdivision.type).to eq "technical-committee"
      end

      it "has schema version" do
        expect(subject.ext.schema_version).to eq Relaton.schema_versions["relaton-model-etsi"]
      end

      it "has correct doctype" do
        expect(subject.ext.doctype).to be_instance_of Relaton::Etsi::Doctype
        expect(subject.ext.doctype.content).to eq "European Standard"
      end

      it "has correct abstract" do
        expect(subject.abstract).to be_instance_of Array
        expect(subject.abstract.first).to be_instance_of Relaton::Bib::Abstract
        expect(subject.abstract.first.content).to eq(
          "The present document specifies interoperability profiles for REM services.",
        )
      end

      it "has correct language" do
        expect(subject.language).to eq ["en"]
      end

      it "has correct script" do
        expect(subject.script).to eq ["Latn"]
      end
    end

    it "#pubid" do
      id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(row).to receive(:[]).with("ETSI deliverable")
        .and_return(id).twice
      pubid = subject.pubid
      expect(pubid).to be_instance_of Relaton::Etsi::PubId
    end

    it "#title" do
      expect(row).to receive(:[]).with("title").and_return("Title").twice
      title = subject.title
      expect(title).to be_instance_of Array
      expect(title.first).to be_instance_of Relaton::Bib::Title
      expect(title.first.content).to eq "Title"
    end

    it "#docnumber" do
      expect(row).to receive(:[]).with("ETSI deliverable").and_return "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(subject.docnumber).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
    end

    it "#source" do
      expect(row).to receive(:[]).with("Details link")
        .and_return("https://www.etsi.org/src").twice
      expect(row).to receive(:[]).with("PDF link")
        .and_return("https://www.etsi.org/pdf").twice
      source = subject.source
      expect(source).to be_instance_of Array
      expect(source.first).to be_instance_of Relaton::Bib::Uri
      expect(source.first.content.to_s).to eq "https://www.etsi.org/src"
      expect(source.first.type).to eq "src"
      expect(source.last.content.to_s).to eq "https://www.etsi.org/pdf"
      expect(source.last.type).to eq "pdf"
    end

    it "#date" do
      id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(row).to receive(:[]).with("ETSI deliverable")
        .and_return(id).at_least(:once)
      date = subject.date
      expect(date).to be_instance_of Array
      expect(date.first).to be_instance_of Relaton::Bib::Date
      expect(date.first.at.to_s).to eq "2023-10"
    end

    it "#docidentifier" do
      id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(row).to receive(:[]).with("ETSI deliverable")
        .and_return(id).twice
      docid = subject.docidentifier
      expect(docid).to be_instance_of Array
      expect(docid.first).to be_instance_of Relaton::Bib::Docidentifier
      expect(docid.first.content).to eq "ETSI EN 319 532-4 V1.3.0 (2023-10)"
    end

    it "#version" do
      id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
      expect(row).to receive(:[]).with("ETSI deliverable")
        .and_return(id).at_least(:once)
      version = subject.version
      expect(version).to be_instance_of Array
      expect(version.first).to be_instance_of Relaton::Bib::Version
      expect(version.first.draft).to eq "1.3.0"
    end

    context "#status" do
      context "approved" do
        before do
          expect(row).to receive(:[]).with("Status")
            .and_return("On Approval").twice
        end

        it "EN" do
          id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
          expect(row).to receive(:[]).with("ETSI deliverable")
            .and_return(id).at_least(:once)
          status = subject.status
          expect(status.stage).to eq "EN approval"
        end

        it "SG" do
          id = "ETSI SG 319 532-4 V1.3.0 (2023-10)"
          expect(row).to receive(:[]).with("ETSI deliverable")
            .and_return(id).at_least(:once)
          status = subject.status
          expect(status.stage).to eq "SG approval"
        end

        it "ES" do
          id = "ETSI ES 319 532-4 V1.3.0 (2023-10)"
          expect(row).to receive(:[]).with("ETSI deliverable")
            .and_return(id).at_least(:once)
          status = subject.status
          expect(status.stage).to eq "ES approval"
        end
      end

      it "#contributor" do
        expect(row).to receive(:[]).with("Technical body").and_return nil
        contrib = subject.contributor
        expect(contrib).to be_instance_of Array
        expect(contrib.first).to be_instance_of Relaton::Bib::Contributor
        expect(contrib.first.organization).to be_instance_of Relaton::Bib::Organization
        expect(contrib.first.organization.name.first.content).to eq "European Telecommunications Standards Institute"
        expect(contrib.first.organization.name.first.language).to eq "en"
        expect(contrib.first.organization.name.first.script).to eq "Latn"
        expect(contrib.first.organization.abbreviation.content).to eq "ETSI"
      end

      it "Published" do
        expect(row).to receive(:[]).with("Status").and_return("Published").twice
        status = subject.status
        expect(status.stage).to eq "Published"
      end
    end

    it "#keyword" do
      expect(row).to receive(:[]).with("Keywords")
        .and_return("Keyword 1,Keyword 2").twice
      expect(subject.keyword.map { |k| k.vocab.content }).to eq ["Keyword 1", "Keyword 2"]
    end

    it "#committee_contributor" do
      expect(row).to receive(:[]).with("Technical body").and_return "WG 1"
      committee = subject.committee_contributor
      expect(committee).to be_instance_of Relaton::Bib::Contributor
      expect(committee.role.first.type).to eq "author"
      expect(committee.role.first.description.first.content).to eq "committee"
      subdivision = committee.organization.subdivision.first
      expect(subdivision).to be_instance_of Relaton::Bib::Subdivision
      expect(subdivision.name.first.content).to eq "WG 1"
      expect(subdivision.type).to eq "technical-committee"
    end

    context "#doctype" do
      it "EN" do
        id = "ETSI EN 319 532-4 V1.3.0 (2023-10)"
        expect(row).to receive(:[]).with("ETSI deliverable")
          .and_return(id).at_least(:once)
        expect(subject.doctype.content).to eq "European Standard"
      end

      it "ES" do
        id = "ETSI ES 319 532-4 V1.3.0 (2023-10)"
        expect(row).to receive(:[]).with("ETSI deliverable")
          .and_return(id).at_least(:once)
        expect(subject.doctype.content).to eq "ETSI Standard"
      end
    end

    it "#abstract" do
      expect(row).to receive(:[]).with("Scope").and_return("Abstract").twice
      abstract = subject.abstract
      expect(abstract).to be_instance_of Array
      expect(abstract.first).to be_instance_of Relaton::Bib::Abstract
      expect(abstract.first.content).to eq "Abstract"
    end
  end
end
