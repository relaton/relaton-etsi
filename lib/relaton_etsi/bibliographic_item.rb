module RelatonEtsi
  class BibliographicItem < RelatonBib::BibliographicItem
    MAKER = %w[Current Superseded].freeze
    CUSTOM_COLLECTION = ["HSs cited in OJ", "HSs not yet cited in OJ", "HSs RED cited in OJ", "HSs EMC cited in OJ"].freeze

    attr_reader :marker, :frequency, :mandate, :custom_collection

    #
    # Constructor.
    #
    # @param [RelatonEtsi::DocumentType] doctype document type
    # @param [String] marker current or superseded
    # @param [Array<String>] frequency list of frequencies
    # @param [Array<String>] mandate list of mandates
    # @param [String, nil] custom_collection custom collection
    #
    def initialize(**args)
      @marker = args.delete(:marker)
      @frequency = args.delete(:frequency) || []
      @mandate = args.delete(:mandate) || []
      @custom_collection = args.delete(:custom_collection)
      super(**args)
    end

    def self.from_hash(hash)
      item_hash = HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end

    #
    # Fetch flavour schema version
    #
    # @return [String] flavour schema versio
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-etsi"]
    end

    def to_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      super(**opts) do |b|
        if opts[:bibdata] && (doctype || subdoctype || editorialgroup || marker || frequency.any? || mandate.any? || custom_collection)
          ext = b.ext do
            doctype&.to_xml b
            b.subdoctype subdoctype if subdoctype
            editorialgroup&.to_xml b
            b.marker marker if marker
            frequency.each { |f| b.frequency f }
            mandate.each { |m| b.mandate m }
            b.send("custom-collection", custom_collection) if custom_collection
          end
          ext["schema-version"] = ext_schema unless opts[:embedded]
        end
      end
    end

    def to_hash # rubocop:disable Metrics/AbcSize
      hash = super
      hash["ext"]["marker"] = marker if marker
      hash["ext"]["frequency"] = frequency if frequency.any?
      hash["ext"]["mandate"] = mandate if mandate.any?
      hash["ext"]["custom_collection"] = custom_collection if custom_collection
      hash
    end

    def has_ext?
      super || marker || frequency.any? || mandate.any? || custom_collection
    end

    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize
      out = super
      pref = prefix.empty? ? prefix : "#{prefix}."
      out += "#{pref}marker:: #{marker}\n" if marker
      out += frequency.map { |f| "#{pref}frequency:: #{f}\n" }.join
      out += mandate.map { |m| "#{pref}mandate:: #{m}\n" }.join
      out += "#{pref}custom_collection:: #{custom_collection}" if custom_collection
      out
    end
  end
end
