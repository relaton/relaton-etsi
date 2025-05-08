# frozen_string_literal: true

require "net/http"
require "open-uri"
require "csv"
require "relaton/index"
require "relaton/bib"
require_relative "etsi/version"
require_relative "etsi/util"
# require_relative "relaton_etsi/pubid"
# require_relative "relaton_etsi/document_type"
require_relative "etsi/item"
require_relative "etsi/bibitem"
require_relative "etsi/bibdata"
# require_relative "relaton_etsi/xml_parser"
# require_relative "relaton_etsi/hash_converter"
# require_relative "relaton_etsi/bibliography"
# require_relative "relaton_etsi/data_fetcher"
# require_relative "relaton_etsi/data_parser"

module Relaton
  module Etsi
    class Error < StandardError; end

    # Returns hash of gem versions used to generate data model.
    # @return [String]
    def grammar_hash
      Digest::MD5.hexdigest Relaton::Etsi::VERSION + Relaton::Bib::VERSION
    end

    extend self
  end
end
