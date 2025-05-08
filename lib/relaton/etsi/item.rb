require_relative "ext"
require_relative "status"

module Relaton
  module Etsi
    class Item < Bib::Item
      model Bib::ItemData

      attribute :ext, Ext
      attribute :status, Status
    end
  end
end
