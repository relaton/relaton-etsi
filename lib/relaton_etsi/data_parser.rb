module RelatonEtsi
  class DataParser
    ATTRS = %i[id title docnumber date docid version status keyword editorialgroup
               doctype abstract language script].freeze

    def initialize(row)
      @row = row
    end

    def parse
      args = ATTRS.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
      BibliographicItem.new(**args)
    end

    def pubid
      @pubid ||= PubId.parse(@row["ETSI deliverable"])
    end

    def id
      @row["ETSI deliverable"].gsub(/[\s\(\)]/, "")
    end

    def title
      [RelatonBib::TypedTitleString.new(content: @row["title"], language: "en", script: "Latn")]
    end

    def docnumber
      @row["ETSI deliverable"]
    end

    def date
      return [] unless pubid.date

      [RelatonBib::BibliographicDate.new(type: "published", on: pubid.date)]
    end

    def docid
      [RelatonBib::DocumentIdentifier.new(id: @row["ETSI deliverable"], type: "ETSI", primary: true)]
    end

    def version
      return [] unless pubid.version

      [RelatonBib::BibliographicItem::Version.new(nil, pubid.version)]
    end

    def status
      status = @row["Status"] == "On Approval" ? "#{pubid.type} approval" : @row["Status"]
      RelatonBib::DocumentStatus.new(stage: status)
    end

    def keyword
      @row["Keywords"].split(",")
    end

    def editorialgroup
      wg = RelatonBib::WorkGroup.new name: @row["Technical body"]
      tc = RelatonBib::TechnicalCommittee.new wg
      RelatonBib::EditorialGroup.new [tc]
    end

    def doctype
      DocumentType.create_from_abbreviation pubid.type
    end

    def abstract
      return [] unless @row["Scope"]

      [RelatonBib::FormattedString.new(content: @row["Scope"], language: "en", script: "Latn")]
    end

    def language
      ["en"]
    end

    def script
      ["Latn"]
    end
  end
end
