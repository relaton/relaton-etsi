module RelatonEtsi
  class DataFetcher
    PAGE_SIZE = 50

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
      agent = Mechanize.new
      first_page = fetch_page(agent, 1)
      process_records(first_page)
      fetch_remaining_pages(agent, first_page)
      index1.save
    end

    def fetch_remaining_pages(agent, first_page)
      total = first_page.first ? first_page.first["total_count"].to_i : 0
      total_pages = (total / PAGE_SIZE.to_f).ceil
      (2..total_pages).each do |page|
        records = fetch_page(agent, page)
        break if records.empty?

        process_records(records)
      end
    end

    def fetch_page(agent, page)
      JSON.parse(agent.get(url(page)).body)
    end

    def process_records(records)
      records.each do |record|
        save DataParser.new(normalize(record)).parse
      end
    end

    def url(page)
      date = Time.now.to_date + 1
      timestamp = (Time.now.to_f * 1000).to_i
      "https://www.etsi.org/custom/standardssearch/data.php?format=json&includeScope=1&" \
        "page=#{page}&search=&title=1&etsiNumber=1&content=1&version=0&onApproval=1&" \
        "published=1&withdrawn=1&historical=1&isCurrent=1&superseded=1&" \
        "startDate=1988-01-15&endDate=#{date}&harmonized=0&keyword=&TB=&stdType=&" \
        "frequency=&mandate=&collection=&sort=1&x=#{timestamp}"
    end

    def normalize(record)
      {
        "ETSI deliverable" => record["ETSI_DELIVERABLE"],
        "title" => record["TITLE"],
        "Details link" => "https://webapp.etsi.org/workprogram/Report_WorkItem.asp?WKI_ID=#{record['wki_id']}",
        "PDF link" => "https://www.etsi.org/deliver/#{record['EDSpathname']}#{record['EDSPDFfilename']}",
        "Status" => derive_status(record),
        "Keywords" => record["Keywords"].to_s,
        "Technical body" => record["TB"],
        "Scope" => record["Scope"],
      }
    end

    def derive_status(record)
      return "Withdrawn" if record["ACTION_TYPE"] == "WD"

      code = record["STATUS_CODE"].to_i
      return "On Approval" if code < 12
      return "Historical" if code == 13

      "Published"
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
