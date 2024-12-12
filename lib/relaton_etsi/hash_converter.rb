module RelatonEtsi
  module HashConverter
    include RelatonBib::HashConverter
    extend self

    def hash_to_bib(hash) # rubocop:disable Metrics/AbcSize
      ret = super
      ret[:marker] = hash["ext"]["marker"] if hash.dig("ext", "marker")
      ret[:frequency] = hash["ext"]["frequency"] if hash.dig("ext", "frequency")
      ret[:mandate] = hash["ext"]["mandate"] if hash.dig("ext", "mandate")
      ret[:custom_collection] = hash["ext"]["custom_collection"] if hash.dig("ext", "custom_collection")
      ret
    end

    private

    # @param item_hash [Hash]
    # @return [RelatonEtsi::BibliographicItem]
    def bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
