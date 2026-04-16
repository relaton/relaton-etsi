require_relative "doctype"

module Relaton
  module Etsi
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :marker, :string, values: %w[Current Superseded]
      attribute :frequency, :string, collection: true
      attribute :mandate, :string, collection: true
      attribute :custom_collection, :string, values: %W[
        HSs\scited\sin\sOJ HSs\snot\syet\scited\sin\sOJ HSs\sRED\scited\sin\sOJ HSs\sEMC\scited\sin\sOJ
      ]

      xml do
        map_element "marker", to: :marker
        map_element "frequency", to: :frequency
        map_element "mandate", to: :mandate
        map_element "custom-collection", to: :custom_collection
      end

      key_value do
        map_element "marker", to: :marker
        map_element "frequency", to: :frequency
        map_element "mandate", to: :mandate
        map_element "custom_collection", to: :custom_collection
      end

      def get_schema_version = Relaton.schema_versions["relaton-model-etsi"]
    end
  end
end
