module Relaton
  module Etsi
    class Doctype < Bib::Doctype
      ABBREVS = %w[EN ES EG TS GS GR TR ETR GTS SR TCRTR TBR ETS I-ETS NET].freeze
      TYPES = %W[
        European\sStandard ETSI\sStandard ETSI\sGuide Technical\sSpecification Group\sSpecification
        Group\sReport Technical\sReport ETSI\sTechnical\sReport GSM\sTechnical\sSpecification
        Special\sReport Technical\sCommittee\sReference\sTechnical\sReport Technical\sBasis\sfor\sRegulation
        European\sTelecommunication\sStandard Interim\sEuropean\sTelecommunication\sStandard
        Norme Européenne\sde\sTélécommunication
      ].freeze

      attribute :abbreviation, :string, values: ABBREVS
      attribute :content, :string, values: TYPES
    end
  end
end
