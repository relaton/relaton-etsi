# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

relaton-etsi is a Ruby gem that retrieves ETSI (European Telecommunications Standards Institute) standards metadata using the Relaton bibliographic item model. It fetches data from the ETSI website and the relaton-data-etsi GitHub repository.

## Commands

```bash
# Install dependencies
bin/setup

# Run all tests
rake spec

# Run a specific test file
rspec spec/relaton/etsi/bibliography_spec.rb

# Run a specific test by line number
rspec spec/relaton/etsi/bibliography_spec.rb:15

# Run linter
rake rubocop

# Interactive console
bin/console

# Install gem locally
bundle exec rake install
```

## Architecture

The codebase is transitioning from `RelatonEtsi` namespace to `Relaton::Etsi` namespace.

### New Architecture (lib/relaton/etsi/)

Uses Lutaml for serialization:
- `Item` - base bibliographic item inheriting from `Bib::Item`
- `Bibitem` - for `<bibitem>` XML output (includes `Bib::BibitemShared`)
- `Bibdata` - for `<bibdata>` XML output (includes `Bib::BibdataShared`)
- `Ext` - ETSI-specific extension data (marker, frequency, mandate, custom_collection)
- `Doctype` - ETSI document type with abbreviations (EN, ES, GS, TS, TR, etc.)

### Legacy Architecture (lib/relaton_etsi/)

- `BibliographicItem` - extends `RelatonBib::BibliographicItem`
- `XMLParser` - parses XML into bibliographic items
- `HashConverter` - converts hashes to bibliographic items
- `DocumentType` - document type with type/abbreviation mapping

### Core Components

- `Bibliography` - searches and retrieves standards from relaton-data-etsi index
- `DataFetcher` - fetches all documents from ETSI website CSV export
- `DataParser` - parses CSV rows into bibliographic items
- `Processor` - Relaton processor for integration with the relaton ecosystem

### Data Flow

1. `Bibliography.get(ref)` searches the relaton-data-etsi index. `Bibliography#best_match` keeps the rows that match the whole document number, then picks the highest version, and among equal versions the latest date. The index matches a String query with `include?`, so this filter is what stops `ETSI TS 103 1` from matching `ETSI TS 103 104`.
2. Fetches YAML from GitHub, converts to `Item` using `from_yaml`
3. `DataFetcher.fetch` pulls CSV from etsi.org, parses with `DataParser`, saves to output folder

## Testing

- **Index fixture:** `spec/fixtures/index-v1.zip` is pre-loaded into `Relaton::Index` pool in `before(:suite)` (configured in `spec/support/webmock.rb`). Run `rake spec:update_index` to refresh from relaton-data-etsi.
Uses RSpec with VCR for HTTP interaction recording. VCR cassettes are in `spec/vcr_cassettes/`. When tests make new HTTP requests, VCR will record them.
