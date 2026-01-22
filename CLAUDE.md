# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Install dependencies
bin/setup

# Run all tests
bundle exec rake spec

# Run a single test file
bundle exec rspec spec/relaton_etsi/bibliography_spec.rb

# Run a single test by line number
bundle exec rspec spec/relaton_etsi/bibliography_spec.rb:15

# Run linter
bundle exec rubocop

# Run linter with auto-fix
bundle exec rubocop -a

# Interactive console for experimentation
bin/console
```

## Architecture

This gem is part of the [Relaton](https://github.com/relaton) ecosystem for retrieving and managing bibliographic data from standards organizations. It specifically handles ETSI (European Telecommunications Standards Institute) standards.

### Core Dependencies
- `relaton-bib` - Base bibliographic classes that this gem extends
- `relaton-index` - Document indexing for search functionality

### Key Classes

**Entry Points:**
- `Bibliography` - Main API: `RelatonEtsi::Bibliography.get("ETSI GS ZSM 012 V1.1.1")` searches the Relaton index and returns a `BibliographicItem`
- `Processor` - Relaton integration point, registered with the main relaton gem

**Data Model:**
- `BibliographicItem` extends `RelatonBib::BibliographicItem` with ETSI-specific fields: `marker`, `frequency`, `mandate`, `custom_collection`
- `DocumentType` - ETSI document type abbreviations (EN, ES, EG, TS, GS, GR, TR, etc.) and their full names
- `PubId` - Parser for ETSI document identifiers, extracting type, docnumber, version, edition, and date

**Data Fetching:**
- `DataFetcher` - Bulk fetches all documents from www.etsi.org CSV export
- `DataParser` - Transforms CSV rows into `BibliographicItem` objects

**Serialization:**
- `XMLParser` extends `RelatonBib::XMLParser` for ETSI-specific XML parsing
- `HashConverter` includes `RelatonBib::HashConverter` for YAML/Hash conversion

### Data Flow
1. `Bibliography.search` queries the GitHub-hosted index (`relaton-data-etsi`)
2. Matching documents are fetched as YAML from the data repository
3. `HashConverter` transforms YAML to constructor arguments
4. `BibliographicItem` is instantiated and returned

For bulk data generation, `DataFetcher` downloads CSV from etsi.org, parses each row with `DataParser`, and saves to files.

## Testing

Tests use VCR cassettes in `spec/vcr_cassettes/` to record/replay HTTP interactions. When updating tests that make HTTP calls, delete the relevant cassette to re-record.
