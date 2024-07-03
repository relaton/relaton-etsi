# frozen_string_literal: true

require "net/http"
require "open-uri"
require "csv"
require "relaton/index"
require "relaton_bib"
require_relative "relaton_etsi/version"
require_relative "relaton_etsi/util"
require_relative "relaton_etsi/pubid"
require_relative "relaton_etsi/document_type"
require_relative "relaton_etsi/bibliographic_item"
require_relative "relaton_etsi/xml_parser"
require_relative "relaton_etsi/hash_converter"
require_relative "relaton_etsi/bibliography"
require_relative "relaton_etsi/data_fetcher"
require_relative "relaton_etsi/data_parser"

module RelatonEtsi
  class Error < StandardError; end

  # Returns hash of gem versions used to generate data model.
  # @return [String]
  def grammar_hash
    Digest::MD5.hexdigest RelatonEtsi::VERSION + RelatonBib::VERSION
  end

  extend self
end
