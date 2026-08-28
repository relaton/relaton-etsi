# frozen_string_literal: true

module Relaton
  module Etsi
    # Methods for search IANA standards.
    module Bibliography
      SOURCE = "https://raw.githubusercontent.com/relaton/relaton-data-etsi/refs/heads/v2/"

      # What follows the document number in an index id: the part numbers, then
      # the version. A reference matches a whole number only, so a part number
      # is optional but a group of digits of the number is not.
      SUFFIX = /\A(?:-\d+)*\s(?:V\d|ed\.\d)/

      # @param text [String]
      # @return [Relaton::Etsi::ItemData, nil]
      def search(text) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        index = Relaton::Index.find_or_create :etsi, url: "#{SOURCE}index-v1.zip", file: INDEX_FILE
        row = best_match(index, text)
        return unless row

        url = "#{SOURCE}#{row[:file]}"
        resp = Net::HTTP.get_response URI(url)
        return unless resp.code == "200"

        Item.from_yaml(resp.body).tap { |item| item.fetched = Date.today.to_s }
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
             EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError, Errno::ETIMEDOUT => e
        raise Relaton::RequestError, e.message
      end

      # @param ref [String] the ETSI standard Code to look up
      # @param year [String, nil] year
      # @param opts [Hash] options
      # @return [Relaton::Etsi::ItemData, nil]
      def get(ref, _year = nil, _opts = {})
        Util.info "Fetching from Relaton repository ...", key: ref
        result = search(ref)
        unless result
          Util.info "Not found.", key: ref
          return
        end

        Util.info "Found: `#{result.docidentifier[0].content}`", key: ref
        result
      end

      # Match the reference against the index and return the newest edition.
      #
      # An index id renders as `ETSI <type> <number> <V1.2.3|ed.4> (<yyyy-mm>)`.
      # The index matches a String query with `include?`, so a bare reference
      # matches every edition of the document, but also longer numbers. The
      # `matches?` filter drops the longer numbers, then `edition_key` picks the
      # highest version, and among equal versions the latest date.
      #
      # @param index [Relaton::Index::Type]
      # @param text [String] the reference
      # @return [Hash, nil] the winning index row (`{ id:, file: }`)
      def best_match(index, text)
        ref = normalize(text)
        index.search(ref)
          .select { |row| matches? ref, row[:id] }
          .max_by { |row| edition_key row[:id] }
      end

      private

      # Every index id has the `ETSI` prefix. A reference can omit it.
      #
      # @param text [String] the reference
      # @return [String]
      def normalize(text)
        ref = text.strip.squeeze(" ").sub(/\AETSI\s+/i, "")
        "ETSI #{ref}"
      end

      # `ETSI EN 319 142` matches every part of the document. Neither
      # `ETSI EN 319 14` nor `ETSI EN 319` matches anything: the first stops
      # inside a group of digits, the second stops before the last group.
      #
      # @param ref [String] the normalized reference
      # @param id [String] the index id
      # @return [Boolean]
      def matches?(ref, id)
        return true if id == ref

        rest = id[ref.length..]
        !rest.nil? && rest.match?(SUFFIX)
      end

      # Sort key of one edition. The numbers keep `V19.0.0` above `V9.0.0` and
      # `ed.11` above `ed.9`, which a comparison of the strings does not. The id
      # is the last element to make the order of equal editions stable.
      #
      # A `V` version and an `ed.` edition give keys of a different length. No
      # ETSI document has the two forms together, and `matches?` keeps the rows
      # of one document number only, so the two forms do not meet here.
      #
      # @param id [String] the index id
      # @return [Array]
      def edition_key(id)
        version = id[/\sV(\d+(?:\.\d+)*)/, 1] || id[/\sed\.(\d+)/, 1] || ""
        [version.split(".").map(&:to_i), id[/\((\d{4}-\d{2})\)/, 1].to_s, id]
      end

      extend Bibliography
    end
  end
end
