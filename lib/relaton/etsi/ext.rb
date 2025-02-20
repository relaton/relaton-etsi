require_relative "doctype"

module Relaton
  module Etsi
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string
      attribute :doctype, Doctype
      attribute :subdoctype, :string
      attribute :editorialgroup, Bib::EditorialGroup
      attribute :marker, :string, values: %w[Current Superseded]
      attribute :frequency, :string, collection: true
      attribute :mandate, :string, collection: true
      attribute :custom_collection, :string, values: %W[
        HSs\scited\sin\sOJ HSs\snot\syet\scited\sin\sOJ HSs\sRED\scited\sin\sOJ HSs\sEMC\scited\sin\sOJ
      ]

      xml do
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "editorialgroup", to: :editorialgroup
        map_element "marker", to: :marker
        map_element "frequency", to: :frequency
        map_element "mandate", to: :mandate
        map_element "custom-collection", to: :custom_collection
      end
    end
  end
end
