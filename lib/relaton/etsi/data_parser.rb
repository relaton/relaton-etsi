require_relative "pubid"
module Relaton
  module Etsi
    class DataParser
      ATTRS = %i[
        title docnumber source date docidentifier version status contributor
        keyword ext abstract language script
      ].freeze

      def initialize(row, errors = {})
        @row = row
        @errors = errors
      end

      def parse
        args = ATTRS.to_h { |attr| [attr, send(attr)] }
        ItemData.new(type: "standard", **args)
      end

      def pubid
        return @pubid if defined?(@pubid)

        unless @row["ETSI deliverable"]
          @errors[:pubid] &&= true
          @pubid = nil
          return @pubid
        end

        @errors[:pubid] &&= false
        @pubid = PubId.parse(@row["ETSI deliverable"])
      end

      def title
        result = if @row["title"]
                   [Bib::Title.new(
                     content: @row["title"], language: "en", script: "Latn",
                   )]
                 else
                   []
                 end
        @errors[:title] &&= result.empty?
        result
      end

      def docnumber
        @row["ETSI deliverable"]
      end

      def source
        urls = []
        if @row["Details link"]
          urls << Bib::Uri.new(content: @row["Details link"], type: "src")
        end
        if @row["PDF link"]
          urls << Bib::Uri.new(content: @row["PDF link"], type: "pdf")
        end
        @errors[:source] &&= urls.empty?
        urls
      end

      def date
        result = if pubid&.date
                   [Bib::Date.new(type: "published", at: pubid.date)]
                 else
                   []
                 end
        @errors[:date] &&= result.empty?
        result
      end

      def docidentifier
        result = if @row["ETSI deliverable"]
                   [Bib::Docidentifier.new(
                     content: @row["ETSI deliverable"],
                     type: "ETSI",
                     primary: true,
                   )]
                 else
                   []
                 end
        @errors[:docidentifier] &&= result.empty?
        result
      end

      def version
        return [] unless pubid&.version

        [Bib::Version.new(draft: pubid.version)]
      end

      def status
        unless @row["Status"]
          @errors[:status] &&= true
          return
        end

        stage = @row["Status"]
        if stage == "On Approval"
          stage = "#{pubid&.type} approval"
        end
        @errors[:status] &&= false
        Status.new(stage: stage)
      end

      def contributor
        contribs = [publisher_contributor]
        contribs << committee_contributor if @row["Technical body"]
        contribs
      end

      def publisher_contributor
        org = Bib::Organization.new(
          name: [etsi_org_name], abbreviation: etsi_abbreviation,
        )
        role = Bib::Contributor::Role.new(type: "publisher")
        Bib::Contributor.new(organization: org, role: [role])
      end

      def etsi_org_name
        Bib::TypedLocalizedString.new(
          content: "European Telecommunications Standards Institute",
          language: "en",
          script: "Latn",
        )
      end

      def etsi_abbreviation
        Bib::LocalizedString.new(
          content: "ETSI",
          language: "en",
          script: "Latn",
        )
      end

      def committee_contributor
        desc = Bib::LocalizedMarkedUpString.new(content: "committee")
        role = Bib::Contributor::Role.new(
          type: "author", description: [desc],
        )
        Bib::Contributor.new(organization: committee_org, role: [role])
      end

      def committee_org
        Bib::Organization.new(
          name: [etsi_name],
          abbreviation: etsi_abbreviation,
          subdivision: [technical_committee_subdivision],
        )
      end

      def etsi_name
        Bib::TypedLocalizedString.new(
          content: "European Telecommunications Standards Institute",
        )
      end

      def technical_committee_subdivision
        Bib::Subdivision.new(
          name: [Bib::TypedLocalizedString.new(
            content: @row["Technical body"],
          )],
          type: "technical-committee",
        )
      end

      def keyword
        unless @row["Keywords"]
          @errors[:keyword] &&= true
          return []
        end

        result = @row["Keywords"].split(",").map do |kw|
          Bib::Keyword.new(vocab: Bib::LocalizedString.new(content: kw.strip, language: "en", script: "Latn"))
        end
        @errors[:keyword] &&= result.empty?
        result
      end

      def ext
        Ext.new(doctype: doctype, flavor: "etsi")
      end

      def doctype
        return unless pubid

        Doctype.create_from_abbreviation pubid.type
      end

      def abstract
        result = if @row["Scope"]
                   [Bib::Abstract.new(content: @row["Scope"], language: "en", script: "Latn")]
                 else
                   []
                 end
        @errors[:abstract] &&= result.empty?
        result
      end

      def language
        ["en"]
      end

      def script
        ["Latn"]
      end
    end
  end
end
