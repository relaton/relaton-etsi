module RelatonEtsi
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = {
      "EN" => "European Standard",
      "ES" => "ETSI Standard",
      "EG" => "ETSI Guide",
      "TS" => "Technical Specification",
      "GS" => "Group Specification",
      "GR" => "Group Report",
      "TR" => "Technical Report",
      "ETR" => "ETSI Technical Report",
      "GTS" => "GSM Technical Specification",
      "SR" => "Special Report",
      "TCRTR" => "Technical Committee Reference Technical Report",
      "TBR" => "Technical Basis for Regulation",
      "ETS" => "European Telecommunication Standard",
      "I-ETS" => "Interim European Telecommunication Standard",
      "NET" => "Norme Européenne de Télécommunication",
    }.freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      check_abbreviation abbreviation
      abbreviation ||= DOCTYPES.key(type)
      super
    end

    def self.create_from_abbreviation(abbreviation)
      new type: DOCTYPES[abbreviation], abbreviation: abbreviation
    end

    private

    def check_type(type)
      return if DOCTYPES.value? type

      Util.warn "invalid doctype: `#{type}`"
    end

    def check_abbreviation(abbreviation)
      return if abbreviation.nil? || DOCTYPES.key?(abbreviation)

      Util.warn "invalid doctype abbreviation: `#{abbreviation}`"
    end
  end
end
