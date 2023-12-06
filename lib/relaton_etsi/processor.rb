require "relaton/processor"

module RelatonEtsi
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_etsi
      @prefix = "ETSI"
      @defaultprefix = %r{^ETSI\s}
      @idtype = "ETSI"
      @datasets = %w[etsi-csv]
    end

    # @param code [String]
    # @param date [String, nil] year
    # @param opts [Hash]
    # @return [RelatonEtsi::BibliographicItem]
    def get(code, date, opts)
      ::RelatonEtsi::Bibliography.get(code, date, opts)
    end

    #
    # Fetch all the documents from http://xml2rfc.tools.ietf.org/public/rfc/bibxml-3gpp-new/
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
    end

    # @param xml [String]
    # @return [RelatonEtsi::BibliographicItem]
    def from_xml(xml)
      ::RelatonEtsi::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonEtsi::BibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonEtsi::HashConverter.hash_to_bib(hash)
      ::RelatonEtsi::BibliographicItem.new(**item_hash)
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonEtsi.grammar_hash
    end

    #
    # Remove index file
    #
    def remove_index_file
      Relaton::Index.find_or_create(:etsi, url: true, file: Bibliography::INDEX_FILE).remove_file
    end
  end
end
