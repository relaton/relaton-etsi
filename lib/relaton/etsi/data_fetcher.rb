require "date"
require "json"
require "mechanize"
require "relaton/core"
require "relaton/index"
require_relative "../etsi"
require_relative "data_parser"

module Relaton
  module Etsi
    class DataFetcher < Core::DataFetcher
      PAGE_SIZE = 50

      SOURCEURL = "https://www.etsi.org/custom/standardssearch/data.php?format=json&includeScope=1&" \
        "page=%<page>s&search=&title=1&etsiNumber=1&content=1&version=0&onApproval=1&published=1&" \
        "withdrawn=1&historical=1&isCurrent=1&superseded=1&startDate=1988-01-15&endDate=%<date>s&" \
        "harmonized=0&keyword=&TB=&stdType=&frequency=&mandate=&collection=&sort=1&x=%<timestamp>s".freeze

      def index
        @index ||= Relaton::Index.find_or_create :etsi, file: INDEX_FILE
      end

      def log_error(msg)
        Util.error msg
      end

      #
      # Fetch all ETSI documents from the ETSI website.
      #
      # @param [Object] _source unused, required by superclass interface
      #
      def fetch(_source = nil)
        first_page = fetch_page(1)
        process_records(first_page)
        fetch_remaining_pages(first_page)
        index.save
        report_errors
      end

      def fetch_remaining_pages(first_page)
        total = first_page.first ? first_page.first["total_count"].to_i : 0
        total_pages = (total / PAGE_SIZE.to_f).ceil
        (2..total_pages).each do |page|
          records = fetch_page(page)
          break if records.empty?

          process_records(records)
        end
      end

      def fetch_page(page)
        date = Time.now.to_date + 1
        timestamp = (Time.now.to_f * 1000).to_i
        url = format(SOURCEURL, page: page, date: date, timestamp: timestamp)
        JSON.parse(fetch_with_retry(url))
      end

      def process_records(records)
        records.each do |record|
          save DataParser.new(normalize(record), @errors).parse
        end
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

      NETWORK_ERRORS = [
        Mechanize::Error, Net::OpenTimeout, Net::ReadTimeout,
        SocketError, Errno::ECONNRESET
      ].freeze

      def fetch_with_retry(url, retries: 3, delay: 2) # rubocop:disable Metrics/MethodLength
        attempt = 0
        begin
          Mechanize.new.get(url).body
        rescue *NETWORK_ERRORS => e
          attempt += 1
          if attempt <= retries
            Util.info "Fetch failed (#{e.message}), " \
                      "retrying (#{attempt}/#{retries})..."
            sleep delay * attempt
            retry
          end
          raise
        end
      end

      def save(bib)
        id = bib.docidentifier.first.content
        file = output_file id
        File.write file, serialize(bib), encoding: "UTF-8"
        index.add_or_update id, file
      end

      def to_yaml(bib)
        bib.to_yaml
      end

      def to_xml(bib)
        bib.to_xml bibdata: true
      end

      def to_bibxml(bib)
        bib.to_rfcxml
      end
    end
  end
end
