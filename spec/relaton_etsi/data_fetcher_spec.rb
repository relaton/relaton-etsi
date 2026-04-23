describe RelatonEtsi::DataFetcher do
  subject { RelatonEtsi::DataFetcher.new "dir", "bibxml" }

  it "initilizes" do
    expect(subject.instance_variable_get(:@output)).to eq "dir"
    expect(subject.instance_variable_get(:@format)).to eq "bibxml"
    expect(subject.instance_variable_get(:@ext)).to eq "xml"
  end

  context "fetches" do
    it "default output & format" do
      expect(FileUtils).to receive(:mkdir_p).with("data")
      data_fetcher = double "data_fetcher"
      expect(data_fetcher).to receive(:fetch)
      expect(described_class).to receive(:new).with("data", "yaml").and_return data_fetcher
      described_class.fetch
    end
  end

  context "instance methods" do
    it "#index1" do
      expect(subject.index1).to be_instance_of Relaton::Index::Type
    end

    it "#fetch single page" do
      agent = double("mechanize")
      expect(Mechanize).to receive(:new).and_return agent
      body = '[{"total_count":"1","wki_id":"73740","TITLE":"T",' \
             '"ETSI_DELIVERABLE":"ETSI EN 1 V1.0.0 (2024-01)",' \
             '"STATUS_CODE":"12","ACTION_TYPE":"PU",' \
             '"EDSpathname":"x/","EDSPDFfilename":"y.pdf",' \
             '"Scope":"S","TB":"WG","Keywords":"k"}]'
      expect(agent).to receive(:get).with(kind_of(String)).and_return double("page", body: body)
      data_parser = double "data_parser"
      expect(data_parser).to receive(:parse).and_return :bibitem
      expect(RelatonEtsi::DataParser).to receive(:new).with(kind_of(Hash)).and_return data_parser
      expect(subject).to receive(:save).with(:bibitem)
      expect(subject.index1).to receive(:save)
      subject.fetch
    end

    it "#fetch paginates by total_count" do
      agent = double("mechanize")
      expect(Mechanize).to receive(:new).and_return agent
      page1 = '[' + Array.new(50) {
        '{"total_count":"75","wki_id":"1","ETSI_DELIVERABLE":"ETSI EN 1 V1.0.0 (2024-01)",' \
        '"STATUS_CODE":"12","ACTION_TYPE":"PU","EDSpathname":"","EDSPDFfilename":"",' \
        '"TITLE":"T","Scope":"S","TB":"WG","Keywords":"k"}'
      }.join(",") + ']'
      page2 = '[' + Array.new(25) {
        '{"total_count":"75","wki_id":"1","ETSI_DELIVERABLE":"ETSI EN 1 V1.0.0 (2024-01)",' \
        '"STATUS_CODE":"12","ACTION_TYPE":"PU","EDSpathname":"","EDSPDFfilename":"",' \
        '"TITLE":"T","Scope":"S","TB":"WG","Keywords":"k"}'
      }.join(",") + ']'
      expect(agent).to receive(:get).with(kind_of(String)).and_return(
        double("page1", body: page1),
        double("page2", body: page2),
      )
      allow(RelatonEtsi::DataParser).to receive(:new).and_return double("data_parser", parse: :bibitem)
      allow(subject).to receive(:save)
      expect(subject.index1).to receive(:save)
      subject.fetch
      expect(subject).to have_received(:save).exactly(75).times
    end

    context "#derive_status" do
      it "Withdrawn" do
        expect(subject.send(:derive_status, "ACTION_TYPE" => "WD", "STATUS_CODE" => "12")).to eq "Withdrawn"
      end

      it "On Approval" do
        expect(subject.send(:derive_status, "ACTION_TYPE" => "PU", "STATUS_CODE" => "5")).to eq "On Approval"
      end

      it "Historical" do
        expect(subject.send(:derive_status, "ACTION_TYPE" => "PU", "STATUS_CODE" => "13")).to eq "Historical"
      end

      it "Published" do
        expect(subject.send(:derive_status, "ACTION_TYPE" => "PU", "STATUS_CODE" => "12")).to eq "Published"
      end
    end

    it "#normalize maps JSON keys to CSV-compatible keys" do
      record = {
        "ETSI_DELIVERABLE" => "ETSI EN 1 V1.0.0 (2024-01)",
        "TITLE" => "Title",
        "wki_id" => "73740",
        "EDSpathname" => "etsi_gr/ZSM/001/",
        "EDSPDFfilename" => "doc.pdf",
        "STATUS_CODE" => "12", "ACTION_TYPE" => "PU",
        "Keywords" => "k1,k2", "TB" => "ZSM", "Scope" => "S"
      }
      hash = subject.send(:normalize, record)
      expect(hash["ETSI deliverable"]).to eq "ETSI EN 1 V1.0.0 (2024-01)"
      expect(hash["title"]).to eq "Title"
      expect(hash["Details link"]).to eq "https://webapp.etsi.org/workprogram/Report_WorkItem.asp?WKI_ID=73740"
      expect(hash["PDF link"]).to eq "https://www.etsi.org/deliver/etsi_gr/ZSM/001/doc.pdf"
      expect(hash["Status"]).to eq "Published"
      expect(hash["Keywords"]).to eq "k1,k2"
      expect(hash["Technical body"]).to eq "ZSM"
      expect(hash["Scope"]).to eq "S"
    end

    it "#save" do
      bibitem = double "bibitem", docidentifier: [double("docidentifier", id: "ETSI A/12 ed.1 (2019-10)")]
      expect(subject).to receive(:content).with(bibitem).and_return :content
      expect(File).to receive(:write).with("dir/ETSI_A-12_ed_1_2019-10.xml", :content, encoding: "UTF-8")
      expect(subject.index1).to receive(:add_or_update).with("ETSI A/12 ed.1 (2019-10)", "dir/ETSI_A-12_ed_1_2019-10.xml")
      subject.save bibitem
    end

    context "#content" do
      it "xml" do
        subject.instance_variable_set :@format, "xml"
        bibitem = double "bibitem"
        expect(bibitem).to receive(:to_xml).with(bibdata: true).and_return :xml
        expect(subject.content(bibitem)).to eq :xml
      end

      it "yaml" do
        subject.instance_variable_set :@format, "yaml"
        bibitem = double "bibitem"
        expect(bibitem).to receive(:to_hash).and_return :hash
        expect(subject.content(bibitem)).to eq "--- :hash\n"
      end

      it "bibxml" do
        bibitem = double "bibitem"
        expect(bibitem).to receive(:to_bibxml).and_return :bibxml
        expect(subject.content(bibitem)).to eq :bibxml
      end
    end
  end
end
