require_relative "item"

module Relaton
  module Etsi
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
