module RelatonEtsi
  class PubId
    class Parser
      def initialize(id)
        @strscan = StringScanner.new id
      end

      def parse
        @strscan.scan(/^ETSI\s+/)
        type = @strscan.scan(/\S+/)
        @strscan.scan(/\s+/)
        docnumber = @strscan.scan_until(/(?=\s(V\d+\.\d+\.\d+)|ed\.\d+)/)
        version = @strscan.scan(/\d+\.\d+\.\d+/) if @strscan.scan(/\sV(?=\d+\.\d+\.\d+)/)
        edition = @strscan.scan(/\d+/) if @strscan.scan(/\sed\.(?=\d+)/)
        date = @strscan.scan(/\d{4}-\d{2}/) if @strscan.scan(/\s\(/)

        { type: type, docnumber: docnumber, version: version, edition: edition, date: date }
      end
    end

    attr_accessor :type, :docnumber, :version, :edition, :date

    def initialize(type:, docnumber:, version:, edition:, date:)
      @type = type
      @docnumber = docnumber
      @version = version
      @edition = edition
      @date = date
    end

    def self.parse(id)
      new(**Parser.new(id).parse)
    end
  end
end
