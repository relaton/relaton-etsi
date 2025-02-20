module Relaton
  module Etsi
    class Status < Lutaml::Model::Serializable
      attribute :stage, :string, values: %W[
        EN\sapproval SG\sapproval ES\sapproval Published Withdrawn Historical
      ]

      xml do
        map_element "stage", to: :stage
      end
    end
  end
end
