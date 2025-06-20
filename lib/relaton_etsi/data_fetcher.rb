module RelatonEtsi
  class DataFetcher
    #
    # Initialize data fetcher.
    #
    # @param [String] output output directory
    # @param [String] format output format (xml, bibxml, yaml)
    #
    def initialize(output, format)
      @output = output
      @format = format
      @ext = format.sub(/^bib/, "")
    end

    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    def index1
      @index1 ||= Relaton::Index.find_or_create :etsi, file: Bibliography::INDEX_FILE
    end

    def fetch
      time = Time.now
      date = time.to_date + 1
      timestamp = (time.to_f * 1000).to_i
      url = "https://www.etsi.org/?option=com_standardssearch&view=data&format=csv&includeScope=1&page=1&search=&" \
            "title=1&etsiNumber=1&content=1&version=0&onApproval=1&published=1&withdrawn=1&historical=1&isCurrent=1&" \
            "superseded=1&startDate=1988-01-15&endDate=#{date}&harmonized=0&keyword=&TB=&stdType=&frequency=&" \
            "mandate=&collection=&sort=1&x=#{timestamp}"
      csv = OpenURI.open_uri(url) { |f| f.readlines.join }
      CSV.parse(csv, headers: true, col_sep: ';', skip_lines: /sep=;/).each do |row|
        save DataParser.new(row).parse
      end
      index1.save
    end

    def save(bib)
      filename = bib.docidentifier.first.id.gsub(/\//, "-").gsub(/\s|\./, "_").gsub(/\(|\)/, "")
      file = File.join @output, "#{filename}.#{@ext}"
      File.write file, content(bib), encoding: "UTF-8"
      index1.add_or_update bib.docidentifier.first.id, file
    end

    def content(bib)
      case @format
      when "xml" then bib.to_xml bibdata: true
      when "yaml" then bib.to_hash.to_yaml
      else bib.send "to_#{@format}"
      end
    end
  end
end
