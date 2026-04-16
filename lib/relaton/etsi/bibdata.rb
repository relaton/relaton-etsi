require_relative "item"

module Relaton
  module Etsi
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
