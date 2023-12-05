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

    it "#fetch" do
      expect(OpenURI).to receive(:open_uri).with(kind_of(String)).and_return "sep=;\r\n\"id\";\r\n\"12\";\r\n"
      data_parser = double "data_parser"
      expect(data_parser).to receive(:parse).and_return :bibitem
      expect(RelatonEtsi::DataParser).to receive(:new).with(kind_of(CSV::Row)).and_return data_parser
      expect(subject).to receive(:save).with(:bibitem)
      expect(subject.index1).to receive(:save)
      subject.fetch
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
