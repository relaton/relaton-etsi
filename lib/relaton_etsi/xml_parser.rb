module RelatonEtsi
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # @param intem [Nokogiri::XML::Document]
      # @return [Hash]
      def item_data(item) # rubocop:disable Metrics/AbcSize
        data = super
        ext = item.at "./ext"
        return data unless ext

        data[:marker] = ext.at("./marker")&.text
        data[:frequency] = ext.xpath("./frequency").map(&:text)
        data[:mandate] = ext.xpath("./mandate").map(&:text)
        data[:custom_collection] = ext.at("./custom-collection")&.text
        data
      end

      # @param item_hash [Hash]
      # @return [RelatonEtsi::BibliographicItem]
      def bib_item(item_hash)
        BibliographicItem.new(**item_hash)
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end

      # def fetch_status(item)
      #   status = item.at "./status"
      #   return unless status

      #   DocumentStatus.new(
      #     stage: status.at("stage")&.text,
      #     substage: status.at("substage")&.text,
      #     iteration: status.at("iteration")&.text,
      #   )
      # end

      # # @param item [Nokogiri::XML::Element]
      # # @return [Array<RelatonBib::DocumentRelation>]
      # def fetch_relations(item)
      #   super item, DocumentRelation
      # end
    end
  end
end
