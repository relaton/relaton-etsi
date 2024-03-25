# frozen_string_literal: true

module RelatonEtsi
  # Methods for search IANA standards.
  module Bibliography
    SOURCE = "https://raw.githubusercontent.com/relaton/relaton-data-etsi/main/"
    INDEX_FILE = "index-v1.yaml"

    # @param text [String]
    # @return [RelatonBib::BibliographicItem]
    def search(text) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      index = Relaton::Index.find_or_create :etsi, url: "#{SOURCE}index-v1.zip", file: INDEX_FILE
      row = index.search(text).min_by { |r| r[:id] }
      return unless row

      url = "#{SOURCE}#{row[:file]}"
      resp = Net::HTTP.get_response URI(url)
      return unless resp.code == "200"

      hash = YAML.safe_load resp.body
      bib_hash = HashConverter.hash_to_bib(hash)
      bib_hash[:fetched] = Date.today.to_s
      BibliographicItem.new(**bib_hash)
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError, Errno::ETIMEDOUT => e
      raise RelatonBib::RequestError, e.message
    end

    # @param ref [String] the ETSI standard Code to look up
    # @param year [String, nil] year
    # @param opts [Hash] options
    # @return [RelatonEtsi::BibliographicItem]
    def get(ref, _year = nil, _opts = {})
      Util.info "Fetching from Relaton repository ...", key: ref
      result = search(ref)
      unless result
        Util.info "Not found.", key: ref
        return
      end

      Util.info "Found: `#{result.docidentifier[0].id}`", key: ref
      result
    end

    extend Bibliography
  end
end
