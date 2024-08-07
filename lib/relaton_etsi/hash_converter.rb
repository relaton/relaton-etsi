module RelatonEtsi
  module HashConverter
    include RelatonBib::HashConverter
    extend self

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
